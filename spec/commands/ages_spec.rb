require 'spec_helper'

describe SlackApplybot::Commands::Ages, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} ages" }
  let(:expected_data) { { channel: { name: 'test' } } }
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

  context 'when the values are all valid' do
    let(:expected_response) { "Apply was deployed yesterday\nCFE was deployed 14 days ago" }
    let(:channel) { 'channel' }

    it 'returns the expected message' do
      Timecop.travel(Date.new(2020, 4, 16)) do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end

    context 'when the user is not in a channel on the allowed list' do
      let(:channel) { 'dangerous' }
      let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

      it 'returns the expected message' do
        Timecop.travel(Date.new(2020, 4, 16)) do
          expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
        end
      end
    end

    context 'when the channel object is missing a name' do
      let(:expected_response) { "Sorry <@user>, I don't understand that command!" }
      let(:expected_body) do
        {
          'ok': true
        }.to_json
      end

      it 'returns the expected message' do
        Timecop.travel(Date.new(2020, 4, 16)) do
          expect(message: user_input, channel: '').to respond_with_slack_message(expected_response)
        end
      end
    end
  end
end
