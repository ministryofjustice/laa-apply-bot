require "rspec"
require "models/user"

describe User, type: :model do
  subject(:user) { described_class.find_or_create_by!(slack_id: "fake_id") }

  it { is_expected.to validate_presence_of(:slack_id) }
  it { is_expected.to validate_uniqueness_of(:slack_id) }

  describe "#otp_secret=" do
    before { user.otp_secret = "secret" }

    it "records an encrypted string" do
      expect(user.reload.encrypted_2fa_secret).to_not eql "secret"
    end

    it "sets enabled_2fa to true" do
      expect(user.reload.enabled_2fa).to be true
    end
  end

  describe "#otp_secret_valid?" do
    before do
      user.otp_secret = "secret"
      user.otp_secret_valid?(value)
    end

    context "when the passed value matches the decrypted version" do
      let(:value) { "secret" }

      it { expect(user.reload.otp_secret_valid?(value)).to be true }
    end

    context "when the encrypted value is different" do
      let(:value) { "public" }

      it { expect(user.reload.otp_secret_valid?(value)).to be false }
    end
  end
end
