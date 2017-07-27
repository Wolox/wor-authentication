require 'spec_helper'

describe Wor::Authentication::VERSION do
  subject(:version) { Wor::Authentication::VERSION }

  it 'has a version number' do
    expect(version).not_to be nil
  end

  it 'has the correct version number' do
    expect(version).to eq('0.2.1')
  end
end
