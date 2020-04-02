source 'https://rubygems.org'
ruby '2.6.5'

gem 'celluloid-io'
gem 'dotenv'
gem 'puma'
gem 'rest-client'
gem 'sidekiq'
gem 'sinatra'
gem 'slack-ruby-bot'

group :development do
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :development, :test do
  gem 'byebug'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'rake'
  gem 'rubocop'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
end
