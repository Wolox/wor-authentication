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

      ##
      # Helpers which may be overrided
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

      def authentication_token
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

      # Explain in README
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
