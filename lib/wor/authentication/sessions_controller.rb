module Wor
  module Authentication
    module SessionsController

      def create
        entity = authenticate_entity(authenticate_params)
        if entity
          token_data = generate_access_token(entity)
          render json: {
            access_token: token_data[:token], renew_id: token_data[:renew_id]
          }, status: :ok
        else
          render_error('Invalid authentication credentials', :unauthorized)
        end
      end

      # TODO: Refactor and remove rubocop exception
      # rubocop:disable Metrics/AbcSize
      def renew
        if !decoded_token.valid_renew_id?(renew_token_params[:renew_id])
          render_error('Invalid renew_id', :unauthorized)
        else
          render json: { access_token: renew_access_token }, status: :ok
        end
      end
      # rubocop:enable Metrics/AbcSize

      def invalidate_all
        # should we rescue anything here ?
        # if invalidating uses db and fails, or something like that
        generate_authenticable_entity_validation(current_entity)
        head :ok
      end

      def generate_access_token(entity)
        renew_id = token_renew_id
        payload = entity_payload(entity).merge(
          entity_custom_validation: authenticable_entity_validation(entity),
          expiration_date: new_token_expiration_date,
          maximum_useful_date: token_maximum_useful_date,
          renew_id: renew_id
        )
        { token: Wor::Authentication::TokenManager.new(token_key).encode(payload), renew_id: renew_id }
      end

      def renew_access_token
        payload = decoded_token.payload
        payload[:expiration_date] = new_token_expiration_date
        Wor::Authentication::TokenManager.new(token_key).encode(payload)
      end

      private

      def current_entity
        current_entity ||= find_authenticable_entity(decoded_token)
      end

      def render_error(error_message, status)
        render json: { error: error_message }, status: status
      end

      # I'm pretty sure this should be set by gems users and not us
      def authenticate_params
        params.require(:session).permit(:email, :password)
      end
      # I'm pretty sure this should be set by gems users and not us
      def renew_token_params
        params.require(:session).permit(:renew_id)
      end

      def render_not_renewable_token
        render_error('Access token is not valid anymore', :unauthorized)
      end

      def render_expired_token
        render_error('Expired token', :unauthorized)
      end

      def render_entity_invalid_custom_validation
        render_error('Entity invalid custom validation', :unauthorized)
      end
    end
  end
end
