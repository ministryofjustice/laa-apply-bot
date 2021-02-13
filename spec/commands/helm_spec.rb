require 'spec_helper'

describe SlackApplybot::Commands::Helm, :vcr do
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
  let(:user_input) { "#{SlackRubyBot.config.user} helm #{command}" }
  let(:command) { '' }

  it_behaves_like 'the channel is invalid'
  context 'when the channel is valid' do
    let(:channel) { 'channel' }
    let(:missing_command_response) { SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm') }
    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to respond_with_slack_message(missing_command_response)
    end
  end
end
