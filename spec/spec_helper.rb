$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'simplecov'

SimpleCov.minimum_coverage 100
unless ENV['NOCOVERAGE']
  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'config/'
    add_group 'Libraries', 'lib/'
  end
  # SimpleCov.at_exit do
  #   say("<%= color('Code coverage below 100%', RED) %>") if SimpleCov.result.coverage_statistics[:line].percent < 100
  #   SimpleCov.result.format!
  # end
end
ENV['ENV'] = 'test'

require 'sidekiq'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

require 'webmock'
require 'webmock/rspec'
WebMock.disable_net_connect!

require 'slack-ruby-bot/rspec'
require 'slack-applybot/commands/details'
require 'slack-applybot/commands/help'
require 'slack-applybot/commands/integration_tests'
require 'slack-applybot/bot'
require 'slack-applybot/environment'
require 'lib/github_values'
require 'lib/monitor_test_run_worker'
require 'lib/send_slack_message'
require 'lib/slack_attachment'
require 'lib/start_integration_tests_worker'
require 'vcr_helper'
require 'app'
require 'dotenv'
Dotenv.load('.env.test')

RSpec.configure do |config|
  config.before do
    stub_request(:post, %r{\Ahttps://slack.com/api/.*\z}).to_return(status: 200, body: '', headers: {})
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200, body: '', headers: {})
  end
end
