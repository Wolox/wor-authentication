require 'jwt'

module Wor
  module Authentication
    class TokenManager
      ENCODING_ALGORITHM = 'HS256'.freeze

      def initialize(key)
        @key = key
      end

      def encode(payload)
        JWT.encode(payload, @key, ENCODING_ALGORITHM)
      end

      def decode(token)
        payload = JWT.decode(token, @key, true, algorithm: ENCODING_ALGORITHM)[0]
        Wor::Authentication::DecodedToken.new(payload)
      rescue StandardError
        raise Wor::Authentication::Exceptions::InvalidAuthorizationToken
      end
    end
  end
end
