require 'jwt'

module Wor
  module Authentication
    module Token
      class Builder
        attr_reader :signed

        def initialize
          @payload = {}
        end

        def fetch(key)
          @payload[key.to_sym] || @payload[key.to_s]
        end

        alias_method :[], :fetch

        def expiration(expiration_date)
          add_claim(:exp, expiration_date)
        end

        def not_before(nbf_date = Wor::Authentication::Token::Constants.current_time)
          add_claim(:nbf, nbf_date)
        end

        def issuer(issuer)
          add_claim(:iss, issuer)
        end

        def subject(subject)
          add_claim(:sub, subject)
        end

        def issued_at(issued_date = Wor::Authentication::Token::Constants.current_time)
          add_claim(:iat, issued_date)
        end

        def jwt_id(jwt_id)
          add_claim(:jti, jwt_id)
        end

        def add_claims(claims = {})
          claims.each do |key, value|
            add_claim(key, value)
          end
          self
        end

        def add_claim(key, value)
          return self if value.nil?
          @payload[key] = value
          self
        end

        def sign(key, alg = Wor::Authentication::Token::Constants::DEFAULT_ALGORITHM)
          @signed = JWT.encode(@payload, key, alg)
          self
        end
      end
    end
  end
end
