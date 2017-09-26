module Wor
  module Authentication
    module Token
      class Decoded
        DEFAULT_ALGORITHM = Wor::Authentication::Token::Constants::DEFAULT_ALGORITHM

        def initialize(token, key, algorithm = DEFAULT_ALGORITHM)
          @token = token
          @key = key
          @algorithm = algorithm
          decode!
        end

        def fetch(key)
          @payload[key.to_sym] || @payload[key.to_s]
        end

        alias_method :[], :fetch

        def validate!(entity, entity_custom_validation = nil)
          raise Wor::Authentication::Exceptions::NoEntityPresent unless entity
          raise Wor::Authentication::Exceptions::CantUseBefore unless can_use?
          raise Wor::Authentication::Exceptions::ExpiredToken if expired?
          if entity_custom_validation && !valid_entity_custom_validation?(entity_custom_validation)
            raise Wor::Authentication::Exceptions::EntityCustomValidationError
          end
        end

        def expired?
          fetch(:exp).present? && current_time > fetch(:exp)
        end

        def able_to_renew?(renew_id)
          fetch(:renew_date).present? && current_time < fetch(:renew_date) && valid_renew_id?(renew_id)
        end

        def can_use?
          fetch(:nbf).present? && current_time >= fetch(:nbf)
        end

        private

        def decode!
          @payload = JWT.decode(@token, @key, true, algorithm: @algorithm)[0]
        rescue StandardError
          raise Wor::Authentication::Exceptions::InvalidAuthorizationToken
        end

        def valid_entity_custom_validation?(entity_custom_validation)
          entity_custom_validation == fetch(:entity_custom_validation)
        end

        def valid_renew_id?(renew_id)
          renew_id == fetch(:renew_id)
        end

        def current_time
          Wor::Authentication::Token::Constants.current_time
        end
      end
    end
  end
end
