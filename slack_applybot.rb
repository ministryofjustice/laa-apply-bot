require 'slack-ruby-bot'
require 'sidekiq'
require './slack-applybot/bot.rb'
require './slack-applybot/environment.rb'
require './slack-applybot/commands/details.rb'
require './slack-applybot/commands/help.rb'
require './slack-applybot/commands/integration_tests.rb'
require './lib/github_values.rb'
require './lib/start_integration_tests_worker.rb'
require './lib/monitor_test_run_worker.rb'
require './lib/slack_attachment.rb'
require 'config'
