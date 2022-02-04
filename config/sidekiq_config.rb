<<<<<<< HEAD
sidekiq_config = { url: ENV['JOB_WORKER_URL'] }
Sidekiq.strict_args!
=======
sidekiq_config = { url: ENV["JOB_WORKER_URL"] }

>>>>>>> 67c58c9 (Address Style/StringLiterals)
Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
