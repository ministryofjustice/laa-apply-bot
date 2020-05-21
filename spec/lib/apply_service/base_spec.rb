require 'spec_helper'

class MockApplication < ApplyService::Base
  def initialize
    super('test')
  end
end

describe ApplyService::Base do
  subject(:base) { described_class.new('test') }

  it { expect { base }.to raise_error(ApplyService::AbstractClassError) }

  context 'when it is instantiated with a missing app name' do
    it 'returns an error message' do
      expect { MockApplication.new }.to raise_error(ApplyService::InvalidApplicationError)
    end
  end
end
