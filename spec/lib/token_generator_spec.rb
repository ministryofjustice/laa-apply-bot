require 'rspec'
require 'lib/token_generator'

RSpec.describe TokenGenerator do
  subject(:token_generator) { described_class.new }

  it { is_expected.to be_a TokenGenerator }

  describe '#call' do
    subject(:call) { described_class.call(slack_id) }

    let(:slack_id) { 'AB2345' }

    it { is_expected.to be_a String }

    context 'that can be parsed via JSON' do
      subject(:decode) { JSON.parse(Base64.urlsafe_decode64(call)) }

      it { expect(decode.keys).to match_array %w[expires_at secret slack_id] }
    end
  end
end
