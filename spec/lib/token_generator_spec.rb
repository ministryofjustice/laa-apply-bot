require 'rspec'
require 'lib/token_generator'

RSpec.describe TokenGenerator do
  subject(:token_generator) { described_class.new }

  it { is_expected.to be_a TokenGenerator }

  describe '#call' do
    subject(:call) { described_class.call(slack_id) }

    let(:slack_id) { 'AB2345' }

    it { is_expected.to be_a String }

    context 'that can be parsed via JSON into an OStruct' do
      subject(:decode) { JSON.parse(Base64.urlsafe_decode64(call), object_class: OpenStruct) }

      it { is_expected.to be_a OpenStruct }
    end
  end
end
