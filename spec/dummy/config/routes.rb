Rails.application.routes.draw do

  # without overriding expiration dates
  post '/', controller: 'default_expiration_dates_authentication', action: :create
  post '/renew', controller: 'default_expiration_dates_authentication', action: :renew
  post '/invalidate_all', controller: 'default_expiration_dates_authentication', action: :invalidate_all

  # overriding expiration dates
  post '/overrided_dates_renew', controller: 'overrided_expiration_dates_authentication', action: :renew

end
