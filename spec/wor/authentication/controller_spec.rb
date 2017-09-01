require 'spec_helper'

describe ApplicationController, type: :controller do
  describe '#authenticate_request' do
    subject { described_class.new }

    context 'without Authorization Header' do
      before do
        subject.request = request
      end

      it 'raises MissingAuthorizationHeader' do
        expect { subject.authenticate_request }
          .to raise_error(Wor::Authentication::Exceptions::MissingAuthorizationHeader)
      end
    end

    context 'with invalid Authorization Header' do
      before do
        request.headers['Authorization'] = 'invalid token'
        subject.request = request
      end

      it 'raises InvalidAuthorizationToken' do
        expect { subject.authenticate_request }
          .to raise_error(Wor::Authentication::Exceptions::InvalidAuthorizationToken)
      end
    end

    context 'with valid Authorization Header' do
      before do
        request.headers['Authorization'] =
          AuthenticationController.new.generate_access_token({})[:token]
        subject.request = request
      end

      it 'does not raise an error' do
        expect { subject.authenticate_request }.not_to raise_error
      end

      it 'has access to the current entity method' do
        expect(subject.current_entity).to be {}
      end
    end
  end
end
