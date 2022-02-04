require "spec_helper"

describe SlackApplybot::Commands::DeployReminder do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: "channel",
      },
    }.to_json
  end
  let(:user_input) do
    [
      {
        'fallback': "gh-user has a pending CFE production approval for master" \
                    " - <https://circleci.com/workflow-run/12345>",
        'text': "gh-user has a pending CFE production approval for master ",
        'id': 1,
        'color': "3AA3E3",
        'fields': [
          {
            'title': "Project",
            'value': "check-financial-eligibility",
            'short': true,
          },
          {
            'title': "Job Number",
            'value': "5009",
            'short': true,
          },
        ],
        'actions': [
          {
            'id': "1",
            'text': "Visit Workflow",
            'type': "button",
            'style': "",
            'url': "https://circleci.com/workflow-run/1234",
          },
        ],
      },
    ]
  end

  let!(:client) { SlackRubyBot::Client.new }
  let!(:message_command) { SlackRubyBot::Hooks::Message.new }
  let(:params) { Hashie::Mash.new(text: "hello", attachments: user_input, channel: "channel", user: "user") }

  it "logs data for analysis" do
    expect(SlackRubyBot::Client.logger).to receive(:warn).once # .with(expected_error)
    message_command.call(client, params)
  end
end
