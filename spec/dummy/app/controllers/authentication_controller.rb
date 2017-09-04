class AuthenticationController < ApplicationController
  include Wor::Authentication::SessionsController
  skip_before_action :authenticate_request, only: [:create]

  def find_authenticable_entity(decoded_token) {} end

  def authenticate_entity(params) {} end

  def entity_payload(entity) {} end
end
