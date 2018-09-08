require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["shiv", "jkaromaticsandperfumers2018"]
end

Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]


Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379', network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379', network_timeout: 5 }
end