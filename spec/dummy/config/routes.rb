Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/' => 'authentication#create'
  post '/renew' => 'authentication#renew'
  post '/invalidate_all' => 'authentication#invalidate_all'
end
