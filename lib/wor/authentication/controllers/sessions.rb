module Wor
  module Authentication
    module Controllers
      module Sessions
        def create
          entity = authenticate_entity(authentication_params)
          return render_error('Invalid authentication credentials', :unauthorized) unless entity
          render json: token_creation_response(entity), status: :created
        rescue ActionController::ParameterMissing
          render_error("Parameter 'session' missing.", :bad_request)
        end

        def renew
          if decoded_token.able_to_renew?(current_entity.try(:renew_id))
            render json: token_creation_response(current_entity), status: :created
          else
            render_error('Invalid renew_id', :unauthorized)
          end
        end

        def invalidate_all
          update_custom_validation_value(current_entity)
          update_renew_id(current_entity)
          head :ok
        end

        ##########################################################################################
        #                   DEFAULT METHOD IMPLEMENTATIONS, USER SHOULD CHANGE                   #
        ##########################################################################################
        def authenticate_entity(params)
          entity = User.find_by(email: authentication_params[:email])
          return nil unless entity.present? && entity.valid_password?(authentication_params[:password])
          entity
        end

        def entity_payload(entity)
          { id: entity.id }
        end

        def new_token_expiration_date
          Wor::Authentication.expiration_minutes.minutes.from_now.to_i
        end

        def new_token_renew_date
          Wor::Authentication.renew_minutes.minutes.from_now.to_i
        end

        def token_renew_id(entity)
          if entity.respond_to?(:renew_id)
            current_key = entity.renew_id
            return current_key if current_key
            update_renew_id(entity)
          end
        end

        def update_custom_validation_value(entity)
          SecureRandom.hex(32).tap do |random_value|
            begin
              entity.update!(entity_custom_validation: random_value)
            rescue
              Rails.logger.info('User does not have a entity_custom_validation attribute')
            end
          end
        end

        def update_renew_id(entity)
          SecureRandom.hex(32).tap do |random_value|
            begin
              entity.update!(renew_id: random_value)
            rescue
              Rails.logger.info('User does not have a renew_id attribute')
            end
          end
        end

        private

        def current_entity
          @current_entity ||= find_authenticable_entity(decoded_token)
        end

        def render_error(error_message, status)
          render json: { error: error_message }, status: status
        end

        def authentication_params
          params.require(:session)
        end

        def renew_token_params
          params.require(:session).permit(:renew_id)
        end

        def token_creation_response(entity)
          token =
            Wor::Authentication::Token::Builder.new
              .expiration(new_token_expiration_date)
              .not_before
              .issued_at
              .add_claims(entity_payload(entity))
              .add_claim(:entity_custom_validation, entity_custom_validation_value(entity))
              .add_claim(:renew_date, new_token_renew_date)
              .add_claim(:renew_id, token_renew_id(entity))
              .sign(token_key)

          new_token_response(token)
        end

        def new_token_response(token)
          {
            access_token: token.signed,
            token_type: 'Bearer',
            expiration_date: token[:exp],
            renew_date: token[:renew_date]
          }
        end
      end
    end
  end
end
