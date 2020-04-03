require './slack_applybot.rb'
require './app.rb'

Thread.abort_on_exception = true
Thread.new do
  SlackApplybot::Bot.run
rescue StandardError => e
  warn "ERROR: #{e}"
  warn e.backtrace
  raise e
end
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'sidekiq' && password == ENV['SIDEKIQ_WEB_UI_PASSWORD'].to_s
end

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
