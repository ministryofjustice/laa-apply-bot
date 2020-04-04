require 'spec_helper'

describe SlackApplybot::Commands::Ages, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} ages" }

  context 'when user request the ages of the apps' do
    let(:expected_response) { "Apply was deployed 1 day ago\nCFE was deployed 1 day ago" }

    it 'starts typing and then returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
    end
  end
end
