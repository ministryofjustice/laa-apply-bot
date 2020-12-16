require 'spec_helper'

describe SlackApplybot::Commands::DeployReminder do
  # let(:user_input) { 'github-user has a pending production approval for master' }
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: 'channel'
      }
    }.to_json
  end
  let(:expected_error) do
    {
      "table":
        {
          "channel": 'channel',
          "channel_name": 'channel',
          "blocks":
            [
              {
                type: 'section',
                block_id: 'error',
                text:
                  {
                    type: 'mrkdwn',
                    text: 'I want to look up github-user, find a slack id and send them a message'
                  }
              }
            ]
        }
    }.to_json
  end
  let(:user_input) do
    [
      {
        type: 'section',
        block_id: 'error',
        text:
          {
            type: 'mrkdwn',
            text: 'I want to look up github-user, find a slack id and send them a message'
          }
      }
    ]
  end

  let!(:client) { SlackRubyBot::Client.new }
  let!(:message_command) { SlackRubyBot::Hooks::Message.new }
  let(:params) { Hashie::Mash.new(text: 'hello', blocks: user_input, channel: 'channel', user: 'user') }

  it 'logs data for analysis' do
    expect(SlackRubyBot::Client.logger).to receive(:warn).with(expected_error)
    message_command.call(client, params)
  end
end
