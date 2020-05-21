require 'sinatra/base'
require 'slack-ruby-bot'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'
require 'dotenv'
require 'rotp'
require 'rqrcode'
require './lib/apply_service/base.rb'
Dir[File.join('lib/**/*.rb')].sort.each do |f|
  file = File.join('.', File.dirname(f), File.basename(f))
  require file
end

require './config/sidekiq_config.rb'

dot_file = ENV['ENV'].eql?('test') ? '.env.test' : '.env'
Dotenv.load(dot_file)

class App < Sinatra::Base
  set :show_exceptions, :after_handler

  get '/' do
    "
    <h1>LAA-Apply bot, find it in slack</h1>
		<p><a href='/sidekiq'>Dashboard</a></p>
		"
  end

  get '/2fa/:token' do |token|
    begin
      values = JSON.parse(Base64.urlsafe_decode64(token), object_class: OpenStruct)
    rescue StandardError
      return 422
    end
    return 403 if Time.now > values.expires_at
    return 403 unless values.secret.eql?(ENV.fetch('SECRET_KEY_BASE'))

    totp = ROTP::TOTP.new(ROTP::Base32.encode(values.slack_id), issuer: ENV.fetch('SERVICE_NAME'))
    qrcode = RQRCode::QRCode.new(totp.provisioning_uri(ENV.fetch('SERVICE_EMAIL')))

    "
    <h1>Your 2FA QR code</h1>
    <ul>
    <li>Open google authenticator, or your 2fa app of choice and point it at the code below</li>
    #{qrcode.as_svg(module_size: 3)}
    <li>When configured, return to slack and, in a DM with apply-bot, type `2fa-check` followed by
        the 6 digit code currently in your authenticator app, e.g. `2fa-check 123456`
    </ul>
    "
  end
end
