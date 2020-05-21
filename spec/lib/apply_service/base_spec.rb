require 'spec_helper'

describe ApplyService::Base do
  subject(:base) { described_class.new }

  it { expect { base }.to raise_error(RuntimeError, 'ApplyService base class cannot be initialized') }
end
