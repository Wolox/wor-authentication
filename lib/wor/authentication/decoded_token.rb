module Wor
  module Authentication
    class DecodedToken
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def validate!(verification_code = nil)
        # this shouldn't be sorted in a different way
        raise Wor::Authentication::Exceptions::InvalidVerificationError unless valid_verification_code?(verification_code)
        raise Wor::Authentication::Exceptions::NotRenewableTokenError unless able_to_renew?
        raise Wor::Authentication::Exceptions::ExpiredTokenError if expired?
      end

      def fetch(key)
        return payload[key.to_sym] unless payload[key.to_sym].nil?
        return payload[key.to_s] unless payload[key.to_s].nil?
        nil
      end

      def expired?
        return false unless fetch(:expiration_date).present?
        # TODO: Use a ruby standard library for time
        Time.zone.now.to_i > fetch(:expiration_date)
      end

      def able_to_renew?
        return false unless fetch(:maximum_useful_date).present?
        # TODO: Use a ruby standard library for time
        Time.zone.now.to_i < fetch(:maximum_useful_date)
      end

      def valid_renew_id?(renew_id)
        return true unless fetch(:renew_id).present? && renew_id.present?
        renew_id == fetch(:renew_id)
      end

      private

      def valid_verification_code?(verification_code)
        return true unless fetch(:verification_code).present?
        verification_code == fetch(:verification_code)
      end
    end
  end
end
