DeviseTokenAuth.setup do |config|
  config.change_headers_on_each_request = false

  # By default, users will need to re-authenticate after 2 weeks. This setting
  # determines how long tokens will remain valid after they are issued.
  config.token_lifespan = 2.weeks

  # Sets the max number of concurrent devices per user, which is 10 by default.
  # After this limit is reached, the oldest tokens will be removed.
  config.max_number_of_devices = 10

  Devise.secret_key = Rails.application.credentials.secret_key_base
end
