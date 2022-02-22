require "spec_helper"

describe SlackApplybot::Commands::IntegrationTests, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} run tests" }
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
      },
    }.to_json
  end
  let(:channel) { "channel" }

  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end

  context "when user requests a test run" do
    it "starts typing and triggers the sidekiq job" do
      expect(Worker::TestRunStart).to receive(:perform_async)
      expect(message: user_input, channel: "channel").to start_typing(channel: "channel")
    end

    it "returns the expected message" do
      expect(message: user_input, channel:).to be_a Hash
    end
  end

  it_behaves_like "the channel is invalid"
end
