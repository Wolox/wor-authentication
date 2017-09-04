module Wor
  module Authentication
    class DecodedToken
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def validate!(entity, entity_custom_validation = nil)
        raise Wor::Authentication::Exceptions::NoEntityPresent unless entity
        raise Wor::Authentication::Exceptions::ExpiredToken if expired?
        if entity_custom_validation && !valid_entity_custom_validation?(entity_custom_validation)
          raise Wor::Authentication::Exceptions::EntityCustomValidationError
        end
      end

      def fetch(key)
        payload[key.to_sym] || payload[key.to_s]
      end

      alias_method :[], :fetch

      def expired?
        # TODO: Use a ruby standard library for time
        fetch(:expiration_date).present? && Time.zone.now.to_i > fetch(:expiration_date)
      end

      def able_to_renew?(renew_id)
        # TODO: Use a ruby standard library for time
        fetch(:renew_date).present? && Time.zone.now.to_i < fetch(:renew_date) && valid_renew_id?(renew_id)
      end

      private

      def valid_entity_custom_validation?(entity_custom_validation)
        entity_custom_validation == fetch(:entity_custom_validation)
      end

      def valid_renew_id?(renew_id)
        renew_id == fetch(:renew_id)
      end
    end
  end
end
