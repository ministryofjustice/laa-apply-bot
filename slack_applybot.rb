require 'slack-ruby-bot'
require 'sidekiq'
require './slack-applybot/bot'
Dir[File.join('slack-applybot/commands/*.rb')].sort.each do |f|
  file = File.join('.', File.dirname(f), File.basename(f))
  require file
end
require './lib/github_values'
require './lib/worker/test_run_start'
require './lib/worker/test_run_locate'
require './lib/worker/test_run_monitor'
