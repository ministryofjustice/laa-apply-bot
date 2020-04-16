require 'spec_helper'

describe SlackApplybot::Commands::Ages, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} ages" }

  context 'when user request the ages of the apps' do
    let(:expected_response) { "Apply was deployed yesterday\nCFE was deployed 14 days ago" }

    it 'starts typing and then returns the expected message' do
      Timecop.travel(Date.new(2020, 4, 16)) do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
      end
    end

    context 'handles textual date responses' do
      let(:expected_response) { "Apply was deployed yesterday\nCFE was deployed 14 days ago" }

      it 'starts typing and then returns the expected message' do
        Timecop.travel(Date.new(2020, 4, 16)) do
          expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
        end
      end
    end
  end
end
