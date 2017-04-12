module Wor
  module Authentication
    class TokenManager
      def initialize(key)
        @key = key
      end

      def encode(payload)
        ## someone reject this line pls: ::JWT
        ::JWT.encode(payload, @key)
      end

      def decode(token)
        ## someone reject this line pls: ::JWT
        payload = ::JWT.decode(token, @key)[0]
        Wor::Authentication::DecodedToken.new(payload)
      rescue
        nil
      end
    end
  end
end
