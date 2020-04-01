require 'sinatra/base'
require 'slack-ruby-bot'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'
require 'dotenv'
require './lib/github_values.rb'
require './lib/start_integration_tests_worker.rb'
require './lib/monitor_test_run_worker.rb'
require './lib/slack_attachment.rb'
require './lib/send_slack_message.rb'
require 'config'

class App < Sinatra::Base
  Dotenv.load

  set :root, File.dirname(__FILE__)
  Config.setup do |config|
    # Name of the constant exposing loaded settings
    config.const_name = 'Settings'
    config.use_env = true
    config.env_prefix = 'SETTINGS'
    config.env_separator = '__'
    config.env_converter = :downcase
  end
  register Config

  get '/' do
    "
    <h1>LAA-Apply bot, find it in slack</h1>
		<p><a href='/sidekiq'>Dashboard</a></p>
		"
  end
end
