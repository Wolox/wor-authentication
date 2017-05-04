require 'spec_helper'

describe Wor::Authentication do
  describe '.config' do
    it 'has configurations' do
      expect(described_class.config).not_to be nil
    end

    it 'has expiration_days' do
      expect(described_class.config[:expiration_days]).not_to be nil
    end

    it 'has expiration_days default value' do
      expect(described_class.config[:expiration_days]).to be 2
    end

    it 'has maximum_useful_days' do
      expect(described_class.config[:maximum_useful_days]).not_to be nil
    end

    it 'has maximum_useful_days default value' do
      expect(described_class.config[:maximum_useful_days]).to be 30
    end
  end

  describe '.configure' do
    let!(:default_expiration_days) { described_class.config[:expiration_days] }
    let!(:default_maximum_useful_days) { described_class.config[:maximum_useful_days] }
    let(:new_expiration_days) { 5 }
    let(:new_maximum_useful_days) { 30 }

    before do
      described_class.configure do |config|
        config.expiration_days = new_expiration_days
        config.maximum_useful_days = new_maximum_useful_days
      end
    end

    it 'can configure new_expiration_days' do
      expect(described_class.config[:expiration_days]).to eq(new_expiration_days)
    end

    it 'can configure maximum_useful_days' do
      expect(described_class.config[:maximum_useful_days]).to eq(new_maximum_useful_days)
    end

    after do
      described_class.configure do |config|
        config.expiration_days = default_expiration_days
        config.maximum_useful_days = default_maximum_useful_days
      end
    end
  end
end
