class DefaultExpirationDatesApplicationController < ActionController::Base
  include Wor::Authentication::Controller
  before_action :authenticate_request

  protect_from_forgery with: :exception

  rescue_from Wor::Authentication::Exceptions::NotRenewableTokenError, with: :render_not_renewable_token
  rescue_from Wor::Authentication::Exceptions::ExpiredTokenError, with: :render_expired_token
  rescue_from Wor::Authentication::Exceptions::EntityCustomValidationError, with: :render_entity_invalid_custom_validation

  def authenticate_entity(params) {} end

  def find_authenticable_entity(decoded_token) {} end

  def entity_payload(entity) {} end
end
