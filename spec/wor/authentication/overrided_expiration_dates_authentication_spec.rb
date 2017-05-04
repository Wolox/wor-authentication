require 'spec_helper'
require 'spy'

describe OverridedExpirationDatesAuthenticationController, type: :controller do

  describe 'POST #renew' do
    let!(:default_expiration_days) { Wor::Authentication.expiration_days }
    let!(:default_maximum_useful_days) { Wor::Authentication.maximum_useful_days }

    before do
      Wor::Authentication.configure do |config|
        config.expiration_days = 5
        config.maximum_useful_days = 20
      end
    end

    after do
      Wor::Authentication.configure do |config|
        config.expiration_days = default_expiration_days
        config.maximum_useful_days = default_maximum_useful_days
      end
    end

    context 'when the session was created' do
      include_context 'With overrided expiration dates session' do
        let(:renew_params) { { renew_id: renew_id } }
      end

      context 'when traveling in time for a value of default token expiration time but new token expiration time is greater' do
        let(:default_expiration_time){ 2.days }
        before do
          Spy.spy(controller, 'entity_custom_validation_renew_value')
          Timecop.travel(Time.zone.now + (default_expiration_time + 1.day))
          post :renew, params: { session: renew_params }
        end

        after do
          Timecop.return
        end

        it 'responds with ok' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the access_token' do
          expect(response.body['access_token']).to be_present
        end

        it 'calls entity_custom_validation_renew_value that may be re-defined by the user' do
          count = controller.spied_entity_custom_validation_renew_value_counter
          expect(count).to be(1)
        end
      end

      context 'when the authentication token has been kept for longer than user-defined maximum time and can\'t be renewed' do
        let(:user_maximum_time){ 20.days }
        before do
          Timecop.travel(Time.zone.now + (user_maximum_time + 1.day))
          post :renew, params: { session: renew_params }
        end

        after do
          Timecop.return
        end

        it 'responds with unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns error message Access token is not valid anymore' do
          expect(JSON.parse(response.body)['error']).to match('Access token is not valid anymore')
        end
      end
    end
  end
end
