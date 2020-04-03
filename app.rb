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
dot_file = ENV['ENV'].eql?('test') ? '.env.test' : '.env'
Dotenv.load(dot_file)

class App < Sinatra::Base
  get '/' do
    "
    <h1>LAA-Apply bot, find it in slack</h1>
		<p><a href='/sidekiq'>Dashboard</a></p>
		"
  end
end
