# Wor-Authentication

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wor-authentication', '~> 0.2.2'
```

And then execute:

`bundle install`

Or install it yourself as:

`gem install wor-authentication`

## Usage

### Basic configuration

The first step is to define a parent controller from which all other controllers will have to extend to have only-authenticated routes. So, let's do that in our `ApplicationController.rb`:

```ruby
class ApplicationController < ActionController::Base
  include Wor::Authentication::Controller
  before_action :authenticate_request
end
```

When a validation fails, an exception will be raised. Feel free to use `Wor::Authentication` helpers to render those errors like the following:

```ruby
rescue_from Wor::Authentication::Exceptions::NotRenewableTokenError, with: :render_not_renewable_token
rescue_from Wor::Authentication::Exceptions::ExpiredTokenError, with: :render_expired_token
rescue_from Wor::Authentication::Exceptions::EntityCustomValidationError, with: :render_entity_invalid_custom_validation
rescue_from Wor::Authentication::Exceptions::MissingAuthorizationHeader, with: :render_missing_authorization_token
rescue_from Wor::Authentication::Exceptions::InvalidAuthorizationToken, with: :render_invalid_authorization_token
```

> To know all the exceptions that can be thrown by the gem, please check the [exceptions file](./lib/wor/authentication/exceptions.rb).

Second and last step, we have to define the routes to achieve authentication and a controller to handle them.

```ruby
# routes.rb
Rails.application.routes.draw do
  # your routes go here
  post '/' => 'authentication#create'
  post '/renew' => 'authentication#renew'
  post '/invalidate_all' => 'authentication#invalidate_all'
end

# authentication_controller.rb
class AuthenticationController < ApplicationController
  include Wor::Authentication::SessionsController
  skip_before_action :authenticate_request, only: [:create]
end
```

> Note that our controller extends from ApplicationController.
> It could also extend from your custom ApiController, for example.

### Entity tracking

#### Override `authenticate_entity`. Add validations for your entity

```ruby
# authentication_controller.rb
def authenticate_entity(params)
  entity = Entity.find_by(some_unique_id: params[:some_unique_id])
  return nil unless entity.present? && entity.valid_password?(params[:password])
  entity
end
```

> Returning no value or false won't create the authentication token.

#### Override `entity_payload`, `find_authenticable_entity` to have access to `current_entity`

```ruby
# application_controller.rb
ENTITY_KEY = :entity_id

def entity_payload(entity)
  { ENTITY_KEY => entity.id }
end

def find_authenticable_entity(entity_payload_returned_object)
  Entity.find_by(id: entity_payload_returned_object.fetch(ENTITY_KEY))
end
```

Overriding these methods will give you access to `current_entity` from any controller that extends `application_controller`.
It will return the entity you used to authenticate.

### Custom Validations

#### Validations in every request? Override `entity_custom_validation_value` to get it verified as the following

```ruby
# application_controller.rb
def entity_custom_validation_value(entity)
   entity.some_value_that_shouldnt_change
end
```

This method will be called before creating the token and in every request to compare if the returned values are the same. If values mismatch, the token won't be valid anymore. If values are the same, expiration validations will be checked.
> If it is desired to update this value when renewing the token, override: `entity_custom_validation_renew_value`.

#### Invalidating all tokens for an entity? Override `entity_custom_validation_invalidate_all_value` as the following

```ruby
# application_controller.rb
def entity_custom_validation_invalidate_all_value(entity)
   entity.some_value_that_shouldnt_change = 'some-new-value'
   entity.save
end
```

This method is the one executed when we want to invalidate sessions for the authenticated entity. An option to achieve that can be to override the value that will be then compared in every request with `entity_custom_validation_value` method, so that initial stored value mismatch with the new different value.
> This works only if `entity_custom_validation_value` has been overridden.

### Some other useful configurations

#### Want to modify tokens TTL or maximum useful days? Set an initializer

```ruby
# config/initializers/wor_authentication.rb
Wor::Authentication.configure do |config|
  config.expiration_days = 5
  config.maximum_useful_days = 20
end
```

Or, even easier, run `rails generate wor:authentication:install` in your root folder.

## About

This project is maintained by [Alejandro Bezdjian](https://github.com/alebian) along with [Michel Agopian](https://github.com/mishuagopian) and it was written by [Wolox](http://www.wolox.com.ar).
![Wolox](https://raw.githubusercontent.com/Wolox/press-kit/master/logos/logo_banner.png)
