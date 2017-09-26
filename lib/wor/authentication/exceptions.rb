module Wor
  module Authentication
    module Exceptions
      class BaseError < StandardError
        MSG = nil

        def message
          return MSG unless MSG.nil?
          exception_name = self.class.to_s.split('::').last
          camel_case_splitted = exception_name.split(/(?=[A-Z])/)
          camel_case_splitted.join(' ')
        end

        def status_code
          :unauthorized
        end
      end

      class InvalidMaximumUsefulDays < BaseError
        MSG = 'maximum_useful_days should be less than expiration_days.'.freeze

        def status_code
          :bad_request
        end
      end

      class InvalidDateType < BaseError
        MSG = 'Date type must be an Integer value.'.freeze

        def status_code
          :bad_request
        end
      end

      class EntityCustomValidationError < BaseError
        MSG = 'Custom validation keys do not match.'.freeze
      end

      class NoKeyProvided < BaseError
        MSG = 'No key provided to sign tokens. Check configuration options.'.freeze

        def status_code
          :bad_request
        end
      end

      class InvalidAuthorizationToken < BaseError
        MSG = 'Provided token has an invalid signature.'.freeze
      end

      class ExpiredToken < BaseError
        MSG = "Token's maximum_useful_date reached.".freeze
      end

      class NotRenewableToken < BaseError
        MSG = "Token's expiration_date reached.".freeze
      end

      class NoEntityPresent < BaseError
        MSG = "Token's owner not found.".freeze
      end

      class MissingAuthorizationHeader < BaseError
        MSG = "Token not found in 'Authorization' header.".freeze
      end

      class CantUseBefore < BaseError
        MSG = "Token can't be used yet, check 'nbf' claim.".freeze
      end
    end
  end
end
