$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dotenv'
Dotenv.load

require 'slack-applybot'
require 'web'

Thread.abort_on_exception = true

Thread.new do
  SlackApplybot::Bot.run
rescue StandardError => e
  warn "ERROR: #{e}"
  warn e.backtrace
  raise e
end

run SlackApplybot::Web
