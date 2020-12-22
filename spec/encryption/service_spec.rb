require 'spec_helper'

describe Encryption::Service do
  subject(:encryption_service) { described_class }

  describe '.encrypt' do
    subject(:encrypting) { encryption_service.encrypt(value) }

    let(:value) { 'plain_text' }

    it { is_expected.to_not eq value }
  end

  describe '.decrypt' do
    subject(:decrypting) { encryption_service.decrypt(encoded) }

    let(:input) { 'plain_text' }
    let(:encoded) { described_class.encrypt(input) }

    it 'can be decoded' do
      is_expected.to eq input
    end
  end
end
