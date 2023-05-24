require 'sidekiq/api'

redis_config = { url: ENV.fetch('REDIS_SIDEKIQ_URL','redis://localhost:6379/2') }

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger.level = :debug
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  config.logger.level = :debug
end
