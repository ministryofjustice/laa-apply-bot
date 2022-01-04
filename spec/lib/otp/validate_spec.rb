require 'rspec'

RSpec.describe OTP::Validate do
  subject(:validate) { described_class.new(user_id, passcode).call }
  let(:encrypted_secret) { Encryption::Service.encrypt('secret') }
  let(:user_id) { 'AB123FAKE' }
  let(:passcode) { '123456' }
  let(:valid_token?) { true }
  let(:user) do
    double('User',
           slack_id: user_id,
           github_id: 'test_gh_user',
           enabled_2fa: true,
           encrypted_2fa_secret: encrypted_secret)
  end

  before do
    allow(User).to receive(:find_by).and_return(user)
    allow_any_instance_of(Encryption::Service).to receive(:decrypt).with(:any).and_return('123456789')
    allow_any_instance_of(ROTP::TOTP).to receive(:verify).with('123456').and_return(true)
    allow_any_instance_of(ROTP::TOTP).to receive(:verify).with('654321').and_return(false)
  end

  context 'when the user and passcode are valid' do
    let(:expected_result) { { valid: true, message: nil } }

    it 'returns the expected json' do
      expect(validate).to match_json_expression expected_result
    end
  end

  context 'when the passcode does not match' do
    subject(:call) { described_class.call(user_id, passcode) }

    let(:passcode) { '654321' }
    let(:expected_result) do
      { valid: false, message: 'OTP password did not match, please check your authenticator app' }
    end

    it 'returns the expected json' do
      expect(call).to match_json_expression expected_result
    end
  end

  context 'when the user has not enabled 2fa' do
    subject(:call) { described_class.call(user_id, passcode) }

    let(:user) { double('User', slack_id: user_id, github_id: nil, enabled_2fa: false, encrypted_2fa_secret: nil) }
    let(:passcode) { '123456' }
    let(:expected_result) do
      { valid: false, message: 'You need to link your github account before you can setup 2FA' }
    end

    it 'returns the expected json' do
      expect(call).to match_json_expression expected_result
    end
  end
end
