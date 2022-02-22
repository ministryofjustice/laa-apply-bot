require "rspec"

RSpec.describe Portal::OutputChannel do
  subject(:output_channel) { described_class.new(channel) }
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:channel) { "shared_channel" }
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel
      }
    }.to_json
  end

  describe "#valid?" do
    subject(:valid?) { output_channel.valid? }

    context "when the channel is the recorded output channel" do
      it { is_expected.to be true }
    end

    context "when the channel is not the recorded output channel" do
      let(:channel) { "channel" }
      it { is_expected.to be false }
    end
  end

  describe ".is" do
    subject(:is) { described_class.is }

    it { is_expected.to eq ENV["USER_OUTPUT_CHANNEL"] }
  end

  describe ".display_name" do
    subject(:display_name) { described_class.display_name }

    it { is_expected.to eq channel }
  end
end
