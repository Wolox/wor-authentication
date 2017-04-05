module Wor
  module Authentication
    module Controller

      def authenticate_request
        entity = find_authenticable_entity(decoded_token)
        decoded_token.validate!(entity_custom_validation_value(entity))
      end

      def decoded_token
        @decoded_token ||= Wor::Authentication::TokenManager.new(token_key).decode(authentication_token)
      end

      ##
      # Helpers intended to override in applications ApplicationController class
      ##

      def token_renew_id
        Devise.friendly_token(32)
      end

      def new_token_expiration_date
        (Time.zone.now + 2.days).to_i
      end

      def token_maximum_useful_date
        (Time.zone.now + 30.days).to_i
      end

      def entity_payload(entity)
        # default instead of exception ?
        # something like: { id: entity.try(:id) }
        # check find_authenticable_entity method and use id instead of user_id if this default value is set
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def authentication_token
        request.headers['Authorization'].split(' ').last
      end

      def entity_custom_validation_value(entity)
        nil
      end

      def entity_custom_validation_renew_value(entity)
        entity_custom_validation_value(entity)
      end

      def entity_custom_validation_invalidate_all_value(entity)
        nil
      end

      def token_key
        raise Wor::Authentication::Exceptions::SubclassMustImplementError unless defined?(Rails)
        raise Wor::Authentication::Exceptions::NoKeyProvidedError if Rails.application.secrets.secret_key_base.nil?
        Rails.application.secrets.secret_key_base
      end

      def authenticate_entity(authenticate_params)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def find_authenticable_entity(decoded_token)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

    end
  end
end
