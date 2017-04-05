module Wor
  module Authentication
    module Controller

      def authenticate_request
        entity = find_authenticable_entity(decoded_token)
        decoded_token.validate!(authenticable_entity_validation(entity))
      end

      def decoded_token
        @decoded_token ||= Wor::Authentication::TokenManager.new(token_key).decode(authentication_token)
      end

      ##
      # Helpers intended to override in controller class
      #

      def new_token_expiration_date
        # default instead of exception ?
        # something like: (Time.zone.now + 2.days).to_i
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def token_maximum_useful_date
        # default instead of exception ?
        # something like: (Time.zone.now + 30.days).to_i
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def entity_payload(entity)
        # default instead of exception ?
        # something like: { id: entity.try(:id) }
        # check find_authenticable_entity method and use id instead of user_id if this default value is set
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def token_renew_id
        # default instead of exception ?
        # if has Devise =====> Devise.friendly_token(32)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def token_key
        raise Wor::Authentication::Exceptions::SubclassMustImplementError unless defined?(Rails)
        raise Wor::Authentication::Exceptions::NoKeyProvidedError if Rails.application.secrets.secret_key_base.nil?
        Rails.application.secrets.secret_key_base
      end

      def authentication_token
        request.headers['Authorization'].split(' ').last
      end

      def authenticable_entity_validation
        nil
      end

      def generate_authenticable_entity_validation(entity)
        true
      end

      def authenticate_entity(authenticate_params)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def find_authenticable_entity(decoded_token)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

      def payload(entity)
        raise Wor::Authentication::Exceptions::SubclassMustImplementError
      end

    end
  end
end
