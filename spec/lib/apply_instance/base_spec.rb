require 'spec_helper'

describe ApplyInstance::Base do
  subject(:base) { described_class.new(type, level) }
  let(:type) { 'apply' }
  let(:level) { 'live' }

  it { expect { base }.to raise_error(RuntimeError, 'ApplyInstance base class cannot be initialized') }
end
