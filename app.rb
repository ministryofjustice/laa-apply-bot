require 'sinatra/base'
require 'sinatra/activerecord'
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

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :show_exceptions, :after_handler
  set :database_file, 'config/database.yml'
  ActiveRecord::Base.logger.level = Logger::WARN if ActiveRecord::Base.logger
  SlackRubyBot::Client.logger.level = Logger::WARN
  SlackRubyBot.configure do |config|
    config.allow_bot_messages = true
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
end
