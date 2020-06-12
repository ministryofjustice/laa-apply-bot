require 'spec_helper'

class MockInstance < ApplyServiceInstance::Base
  def initialize(level)
    super('cccd', level)
  end
end

describe ApplyServiceInstance::Base do
  subject(:base) { described_class.new(type, level) }
  let(:type) { 'apply' }
  let(:level) { 'live' }

  it { expect { base }.to raise_error(ApplyServiceInstance::AbstractClassError) }

  context 'when it is instantiated with a missing app name' do
    it 'returns an error message' do
      expect { MockInstance.new(level) }.to raise_error(ApplyServiceInstance::InvalidApplicationError)
    end
  end
end
