Wor::Authentication.configure do |config|
  config.expiration_minutes = 43200
  config.renew_minutes = 43185
  config.token_key = Rails.application.secrets.secret_key_base
end
