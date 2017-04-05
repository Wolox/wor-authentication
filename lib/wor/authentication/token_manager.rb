module Wor
  module Authentication
    class TokenManager
      def initialize(key)
        @key = key
      end

      def encode(payload)
        JWT.encode(payload, @key)
      end

      def decode(token)
        payload = JWT.decode(token, @key)[0]
        Wor::Authentication::DecodedToken.new(payload)
      rescue
        nil
      end
    end
  end
end
