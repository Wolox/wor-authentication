require 'spec_helper'
require 'spy'

describe AuthenticationController, type: :controller do

  describe 'POST #create' do
    let!(:session_params) { { session_param_1: 'some value' } }
    subject { post :create, params: { session: session_params } }

    context 'when requesting with valid data (always)' do
      before do
        Spy.spy(controller, 'authenticate_entity')
        Spy.spy(controller, 'entity_payload')
        Spy.spy(controller, 'entity_custom_validation_value')
        subject
      end

      it 'responds with ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the access_token' do
        expect(response.body['access_token']).to be_present
      end

      it 'returns the renew_id' do
        expect(response.body['renew_id']).to be_present
      end

      it 'calls authenticate_entity defined by the user' do
        count = controller.spied_authenticate_entity_counter
        expect(count).to be(1)
      end

      it 'calls entity_payload defined by the user' do
        count = controller.spied_entity_payload_counter
        expect(count).to be(1)
      end

      it 'calls entity_custom_validation_value that may be re-defined by the user' do
        count = controller.spied_entity_custom_validation_value_counter
        expect(count).to be(1)
      end
    end
  end

  describe 'POST #renew' do
    context 'when the session was created' do
      include_context 'With session' do
        let(:renew_params) { { renew_id: renew_id } }
      end

      context 'when the authentication token can be renewed' do
        context 'when valid renew_id is sent' do
          before do
            Spy.spy(controller, 'entity_custom_validation_renew_value')
            time = Time.zone.now.tomorrow
            Timecop.freeze(time.year, time.month, time.day, time.hour, time.min, time.sec)
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

        context 'when invalid renew_id is sent' do
          before do
            post :renew, params: { session: { renew_id: 'invalid-renew-id' } }
          end

          after do
            Timecop.return
          end

          it 'responds with ok' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns the access_token' do
            expect(JSON.parse(response.body)['error']).to match('Invalid renew_id')
          end
        end
      end

      context 'when the authentication token is renewed is still usable' do
        before do
          Spy.spy(controller, 'entity_custom_validation_renew_value')
          time = Time.zone.now.tomorrow
          Timecop.freeze(time.year, time.month, time.day, time.hour, time.min, time.sec)
          post :renew, params: { session: renew_params }
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
          expect(count).to be(2)
        end
      end

      context 'when the authentication token has already expired and can\'t be renewed' do
        let(:default_expiration_time) { 2.days }
        before do
          Timecop.travel(Time.zone.now + (default_expiration_time + 1.day))
          post :renew, params: { session: renew_params }
        end

        after do
          Timecop.return
        end

        it 'responds with unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns error message Expired token' do
          expect(JSON.parse(response.body)['error']).to match('Expired token')
        end
      end

      context 'when the authentication token has been kept for longer than maximum time and can\'t be renewed' do
        let(:default_maximum_time) { 30.days }
        before do
          Timecop.travel(Time.zone.now + (default_maximum_time + 1.day))
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

  describe 'POST #invalidate_all' do
    include_context 'With session' do
      let(:renew_params) { { renew_id: renew_id } }
    end

    context 'when the authentication token is valid' do
      before do
        Spy.spy(controller, 'entity_custom_validation_invalidate_all_value')
        post :invalidate_all
      end

      it 'responds with ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'calls entity_custom_validation_invalidate_all_value that may be re-defined by the user' do
        count = controller.spied_entity_custom_validation_invalidate_all_value_counter
        expect(count).to be(1)
      end
    end

    context 'when the authentication token has expired' do
      let(:default_expiration_time) { 2.days }
      before do
        Timecop.travel(Time.zone.now + (default_expiration_time + 1.day))
        post :invalidate_all
      end

      after do
        Timecop.return
      end

      it 'responds with unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message Expired token' do
        expect(JSON.parse(response.body)['error']).to match('Expired token')
      end
    end
  end
end
