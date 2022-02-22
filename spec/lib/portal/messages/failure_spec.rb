require "spec_helper"

describe Portal::Messages::Failure do
  subject(:failure) { described_class.call(names) }
  let(:names) { %w[name1 name2] }
  let(:expected_response) do
    [
      {
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "The following name(s) could not be matched in CCMS"
        }
      },
      {
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "```name1\nname2```"
        }
      },
      {
        'type': "section",
        'text': {
          'type': "mrkdwn",
          'text': "You will need to confirm their account names and re-submit"
        }
      }
    ]
  end

  it "returns the expected blocks" do
    expect(failure).to eq expected_response
  end
end
