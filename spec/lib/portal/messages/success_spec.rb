require "spec_helper"

RSpec.describe Portal::Messages::Success do
  subject(:success) { described_class.call(script) }
  let(:script) { "contents of script" }
  let(:expected_response) do
    [
      {
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "These user names matched in CCMS",
        },
      },
      {
        'block_id': "user-script",
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "```contents of script```",
        },
      },
      {
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "Send this script to the new_user channel?",
        },
      },
      {
        'block_id': "new_user_response",
        'type': "actions",
        'elements': [
          {
            'type': "button",
            'text': {
              'type': "plain_text",
              'emoji': true,
              'text': "Approve",
            },
            'style': "primary",
            'value': "approve",
          },
          {
            'type': "button",
            'text': {
              'type': "plain_text",
              'emoji': true,
              'text': "Reject",
            },
            'style': "danger",
            'value': "reject",
          },
        ],
      },
    ]
  end

  it "returns the expected blocks" do
    expect(success).to eq expected_response
  end
end
