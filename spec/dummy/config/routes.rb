Rails.application.routes.draw do
  post '/', controller: 'authentication', action: :create
  post '/renew', controller: 'authentication', action: :renew
  post '/invalidate_all', controller: 'authentication', action: :invalidate_all
end
