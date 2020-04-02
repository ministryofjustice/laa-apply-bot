require './slack_applybot.rb'
require './app.rb'

Dotenv.load

Thread.abort_on_exception = true
Thread.new do
  SlackApplybot::Bot.run
rescue StandardError => e
  warn "ERROR: #{e}"
  warn e.backtrace
  raise e
end

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
