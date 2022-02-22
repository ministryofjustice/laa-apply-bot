require "spec_helper"

describe Encryption::Service do
  subject(:encryption_service) { described_class }

  describe ".encrypt" do
    subject(:encrypting) { encryption_service.encrypt(value) }

    let(:value) { "plain_text" }

    it { is_expected.not_to eq value }
  end

  describe ".decrypt" do
    subject(:decrypting) { encryption_service.decrypt(encoded) }

    let(:input) { "plain_text" }
    let(:encoded) { described_class.encrypt(input) }

    it "can be decoded" do
      expect(decrypting).to eq input
    end
  end
end
