require 'devise'

module Wor
  module Authentication
    module Controller
      def authenticate_request
        entity = find_authenticable_entity(decoded_token)
        decoded_token.validate!(entity_custom_validation_value(entity))
      end

      def decoded_token
        @decoded_token ||= Wor::Authentication::TokenManager.new(
          token_key
        ).decode(authentication_token)
      end

      def new_token_expiration_date
        Wor::Authentication.expiration_days.days.from_now.to_i
      end

      def token_maximum_useful_date
        Wor::Authentication.maximum_useful_days.days.from_now.to_i
      end

      def current_entity
        @current_entity ||= find_authenticable_entity(decoded_token)
      end

      ##
      # Helpers which may be overridden
      ##

      def token_renew_id
        Devise.friendly_token(32)
      end

      def authentication_token
        if request.headers['Authorization'].blank?
          raise Wor::Authentication::Exceptions::MissingAuthorizationHeader
        end
        request.headers['Authorization'].split(' ').last
      end

      def entity_custom_validation_value(_entity)
        nil
      end

      def entity_custom_validation_renew_value(entity)
        entity_custom_validation_value(entity)
      end

      def entity_custom_validation_invalidate_all_value(_entity)
        nil
      end

      def token_key
        raise Wor::Authentication::Exceptions::SubclassMustImplementError unless defined?(Rails)
        if Rails.application.secrets.secret_key_base.blank?
          raise Wor::Authentication::Exceptions::NoKeyProvidedError
        end
        Rails.application.secrets.secret_key_base
      end

      def authenticate_entity(_params)
        {}
      end

      def find_authenticable_entity(_decoded_token)
        {}
      end

      def entity_payload(_entity)
        {}
      end
    end
  end
end
