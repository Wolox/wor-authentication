module Wor
  module Authentication
    class DecodedToken
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def validate!(entity_custom_validation = nil)
        unless valid_entity_custom_validation?(entity_custom_validation)
          raise Wor::Authentication::Exceptions::EntityCustomValidationError
        end
        raise Wor::Authentication::Exceptions::NotRenewableTokenError unless able_to_renew?
        raise Wor::Authentication::Exceptions::ExpiredTokenError if expired?
      end

      def fetch(key)
        return payload[key.to_sym] if payload[key.to_sym].present?
        return payload[key.to_s] if payload[key.to_s].present?
        nil
      end

      def expired?
        # TODO: Use a ruby standard library for time
        fetch(:expiration_date).present? && Time.zone.now.to_i > fetch(:expiration_date)
      end

      def able_to_renew?
        # TODO: Use a ruby standard library for time
        fetch(:maximum_useful_date).present? && Time.zone.now.to_i < fetch(:maximum_useful_date)
      end

      def valid_renew_id?(renew_id)
        (fetch(:renew_id).blank? || renew_id.blank?) || renew_id == fetch(:renew_id)
      end

      private

      def valid_entity_custom_validation?(entity_custom_validation)
        fetch(:entity_custom_validation).blank? ||
          entity_custom_validation == fetch(:entity_custom_validation)
      end
    end
  end
end
