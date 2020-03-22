$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'slack-ruby-bot/rspec'
require 'slack-applybot/commands/details'
require 'slack-applybot/commands/help'
require 'slack-applybot/bot'
require 'slack-applybot/environment'
require 'vcr_helper'
require 'dotenv'

Dotenv.load('.env.test')
