$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'simplecov'
require 'highline/import'
SimpleCov.minimum_coverage 100
unless ENV['NOCOVERAGE']
  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'config/'
    add_group 'Libraries', 'lib/'
  end
  SimpleCov.at_exit do
    say("<%= color('Code coverage below 100%', RED) %>") if SimpleCov.result.coverage_statistics[:line].percent < 100
    SimpleCov.result.format!
  end
end
ENV['ENV'] = 'test'

require 'timecop'
require 'sidekiq'
require 'sidekiq/testing'
Sidekiq::Testing.fake!
require 'webmock'
require 'webmock/rspec'
WebMock.disable_net_connect!
require 'pry'
require 'slack-ruby-bot/rspec'
require 'vcr_helper'
require 'app'
require 'shoulda/matchers'
require 'dotenv'
Dotenv.load('.env.test')

Dir[File.join('slack-applybot/**/*.rb'), File.join('lib/**/*.rb')].sort.each do |f|
  file = File.join(File.dirname(f), File.basename(f, File.extname(f)))
  require file
end

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.before do
    stub_request(:post, %r{\Ahttps://slack.com/api/.*\z}).to_return(status: 200, body: '', headers: {})
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200, body: '', headers: {})
  end
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
  end
end
