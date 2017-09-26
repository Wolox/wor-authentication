module Wor
  module Authentication
    module Exceptions
      class BaseError < StandardError
        def message
          exception_name = self.class.to_s.split('::').last
          camel_case_splitted = exception_name.split(/(?=[A-Z])/)
          camel_case_splitted.join(' ')
        end

        def status_code
          :unauthorized
        end
      end

      class InvalidMaximumUsefulDays < BaseError
        def message
          'maximum_useful_days should be less than expiration_days.'
        end

        def status_code
          :bad_request
        end
      end

      class InvalidDateType < BaseError
        def message
          'Date type must be an Integer value.'
        end

        def status_code
          :bad_request
        end
      end

      class EntityCustomValidationError < BaseError
        def message
          'Custom validation keys do not match.'
        end
      end

      class NoKeyProvided < BaseError
        def message
          'No key provided to sign tokens. Check configuration options.'
        end

        def status_code
          :bad_request
        end
      end

      class InvalidAuthorizationToken < BaseError
        def message
          'Provided token has an invalid signature.'
        end
      end

      class ExpiredToken < BaseError
        def message
          "Token's maximum_useful_date reached."
        end
      end

      class NotRenewableToken < BaseError
        def message
          "Token's expiration_date reached."
        end
      end

      class NoEntityPresent < BaseError
        def message
          "Token's owner not found."
        end
      end

      class MissingAuthorizationHeader < BaseError
        def message
          "Token not found in 'Authorization' header."
        end
      end

      class CantUseBefore < BaseError
        def message
          "Token can't be used yet, check 'nbf' claim."
        end
      end
    end
  end
end
