require_relative 'authentication/exceptions'
require_relative 'authentication/controller'
require_relative 'authentication/decoded_token'
require_relative 'authentication/sessions_controller'
require_relative 'authentication/token_manager'
require_relative 'authentication/version'

module Wor
  module Authentication
    @config = {
      token_key: nil,
      expiration_minutes: 43200,
      renew_minutes: 43185
    }

    def self.configure
      yield self
      if renew_minutes >= expiration_minutes
        raise Wor::Authentication::Exceptions::InvalidMaximumUsefulDays
      end
    end

    def self.expiration_minutes=(expiration_minutes)
      unless expiration_minutes.is_a? Integer
        raise Wor::Authentication::Exceptions::InvalidDateType
      end
      @config[:expiration_minutes] = expiration_minutes
    end

    def self.renew_minutes=(renew_minutes)
      unless renew_minutes.is_a? Integer
        raise Wor::Authentication::Exceptions::InvalidDateType
      end
      @config[:renew_minutes] = renew_minutes
    end

    def self.token_key=(token_key)
      @config[:token_key] = token_key
    end

    def self.config
      @config
    end

    def self.expiration_minutes
      @config[:expiration_minutes]
    end

    def self.renew_minutes
      @config[:renew_minutes]
    end

    def self.token_key
      @config[:token_key]
    end
  end
end
