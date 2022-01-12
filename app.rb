require 'sinatra/base'
require 'sinatra/activerecord'
require 'active_support/inflections'
require 'slack-ruby-bot'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'
require 'dotenv'

dot_file = ENV['ENV'].eql?('test') ? '.env.test' : '.env'
Dotenv.load(dot_file)

require 'rotp'
require 'rqrcode'
require './lib/apply_service/base'
require './lib/apply_service_instance/base'
Dir[File.join('lib/**/*.rb')].sort.each do |f|
  file = File.join('.', File.dirname(f), File.basename(f))
  require file
end
require './models/user'
require './config/sidekiq_config'
require './config/initializers/inflections'

class NewUserResponse
  def call(values)
    url = values[:response_url]
    action = values[:actions].first
    payload = new_user_response_json(approve_reject_text(action[:value].eql?('approve')))
    RestClient.post(url, payload.to_json, { 'Content-Type': 'application/json' })
    send_file_upload_message(values) if action[:value].eql?('approve')
  end

  def send_file_upload_message(values)
    raw_script = values.dig(:message, :blocks).select { |x| x[:block_id].eql? 'user-script' }.dig(0, :text, :text)
    script = raw_script.gsub('```', '')
    user = values.dig(:user, :id)
    SendSlackMessage.new.upload_file(message_params(script, user))
  end

  def message_params(script, user)
    { channels: Portal::OutputChannel.is, content: script, filename: 'output.ldif', initial_comment: notify_text(user) }
  end

  def notify_text(user)
    '<!here> can you add the following users? ' \
      "<@#{user}> has raised the request and the apply service is ready for them"
  end

  def new_user_response_json(message)
    {
      'replace_original': 'true',
      'text': message
    }
  end

  def approve_reject_text(approve)
    if approve
      "Thanks for your approving, we'll process it and raise the request in <#new-users-apply>."
    else
      "Rejection noted, we aren't taking it personally"
    end
  end
end

class DeleteBranch
  def call(values)
    parts = values[:actions][0][:block_id].split('|')
    service = parts[1]
    branch = parts[2]
    view = Helm::Messages::OTPModal.call(service, [branch])
    SendSlackMessage.new.open_modal(trigger_id: values[:trigger_id], view: view)
  end
end

class OTPResponse
  def call(values)
    otp = values.dig(:view, :state, :values, :otp_response, :otp_action, :value)
    user_id = values.dig(:user, :id)
    otp_result = OTP::Validate.call(user_id, otp)
    if otp_result[:valid]
      parts = extract_values(values)
      message = attempt_delete(parts)
    else
      message = otp_result[:message]
    end
    SendSlackMessage.new.open_modal(trigger_id: values[:trigger_id], view: json_response(message))
    # TODO: get original message and update row to remove row that was successfully deleted... if it was :/
  end

  private

  def extract_values(values)
    values.dig(:view, :blocks).select { |x| x[:block_id].starts_with? 'instances' }.dig(0, :block_id).split('|')
  end

  def json_response(message)
    {
      'type': 'modal',
      'title': { 'type': 'plain_text', 'text': 'ApplyBot - Helm deletion', 'emoji': true },
      'close': { 'type': 'plain_text', 'text': 'Close', 'emoji': true },
      'blocks':
        [
          { 'type': 'section', 'text': { 'type': 'mrkdwn', 'text': message } }
        ]
    }.as_json
  end

  def attempt_delete(parts)
    if Helm::Delete.call(parts[2], parts[1])
      "Instance `#{parts[2]}` deleted from *#{parts[1]}*"
    else
      "Unable to delete `#{parts[2]}` from *#{parts[1]}*"
    end
  end
end

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :show_exceptions, :after_handler
  set :database_file, 'config/database.yml'
  ActiveRecord::Base.logger.level = Logger::WARN if ActiveRecord::Base.logger
  SlackRubyBot::Client.logger.level = Logger::WARN
  SlackRubyBot.configure do |config|
    config.allow_bot_messages = false
  end
  get '/' do
    "
    <h1>LAA-Apply bot, find it in slack</h1>
		<p><a href='/sidekiq'>Dashboard</a></p>
		"
  end

  get '/ping' do
    {
      build_date: ENV['BUILD_DATE'] || 'Not Available',
      build_tag: ENV['BUILD_TAG'] || 'Not Available'
    }.to_json
  end

  post '/interactive' do
    payload = JSON.parse(params['payload'], symbolize_names: true)
    interactive_type = next_step(payload)
    Thread.new { interactive_type.classify.constantize.new.call(payload) }
  rescue StandardError => e
    SlackRubyBot::Client.logger.warn(e.inspect)
  ensure
    # always return empty success response to prevent
    # warnings in slack when buttons are clicked
    halt 200
  end

  private

  def next_step(params)
    block_return(params) || view_return(params)
  end

  def block_return(params)
    params.dig(:actions, 0, :block_id)&.split('|')&.first
  end

  def view_return(params)
    params.dig(:view, :blocks).select { |x| x[:type].eql? 'input' }.dig(0, :block_id)
  end
end
