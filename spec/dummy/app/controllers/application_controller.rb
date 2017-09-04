class ApplicationController < ActionController::Base
  include Wor::Authentication::Controller
  before_action :authenticate_request

  protect_from_forgery with: :exception

  rescue_from Wor::Authentication::Exceptions::NotRenewableToken, with: :render_not_renewable_token
  rescue_from Wor::Authentication::Exceptions::ExpiredToken, with: :render_expired_token

  # Since we don't have a User model
  def find_authenticable_entity(decoded_token) {} end
end
