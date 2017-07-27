module Wor
  module Authentication
    module Exceptions
      class InvalidExpirationDaysError < StandardError; end
      class InvalidMaximumUsefulDaysError < StandardError; end
      class SubclassMustImplementError < StandardError; end
      class NoKeyProvidedError < StandardError; end
      class ExpiredTokenError < StandardError; end
      class NotRenewableTokenError < StandardError; end
      class EntityCustomValidationError < StandardError; end
      class MissingAuthorizationHeader < StandardError; end
      class InvalidAuthorizationToken < StandardError; end
    end
  end
end
