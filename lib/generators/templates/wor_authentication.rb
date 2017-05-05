Wor::Authentication.configure do |config|
  config.expiration_days = 2
  config.maximum_useful_days = 30
end
