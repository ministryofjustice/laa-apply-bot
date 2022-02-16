require './slack_applybot'
require './app'

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
use Rack::Session::Cookie, secret: ENV['SESSION_KEY'], same_site: true, max_age: 86400
run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
