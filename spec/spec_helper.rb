$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'simplecov'

SimpleCov.minimum_coverage 100
unless ENV['NOCOVERAGE']
  SimpleCov.start do
    add_filter 'config/initializers/'
    add_filter 'spec/'
  end
  # SimpleCov.at_exit do
  #   say("<%= color('Code coverage below 100%', RED) %>") if SimpleCov.result.coverage_statistics[:line].percent < 100
  #   SimpleCov.result.format!
  # end
end

require 'slack-ruby-bot/rspec'
require 'slack-applybot/commands/details'
require 'slack-applybot/commands/help'
require 'slack-applybot/bot'
require 'slack-applybot/environment'
require 'vcr_helper'
require 'dotenv'

Dotenv.load('.env.test')
