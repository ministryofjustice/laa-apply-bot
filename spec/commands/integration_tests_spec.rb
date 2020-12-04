require 'spec_helper'

describe SlackApplybot::Commands::IntegrationTests, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} run tests" }
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel
      }
    }.to_json
  end
  let(:channel) { 'channel' }

  context 'when user requests a test run' do
    it 'starts typing and triggers the sidekiq job' do
      expect(TestRunStartWorker).to receive(:perform_async)
      expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to be_a Hash
    end
  end

  context 'when the user is not in a channel on the allowed list' do
    let(:channel) { 'dangerous' }
    let(:app) { 'simon' }
    let(:env) { 'staging' }
    let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

    it 'returns the expected message' do
      Timecop.travel(Date.new(2020, 4, 16)) do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end
  end
end
