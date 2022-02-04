require "spec_helper"
require "support/commit"
describe SlackApplybot::Commands::Ages, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} ages" }
  let(:expected_data) { { channel: { name: "test" } } }
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200, body: commits, headers: {})
    allow(Github::Status).to receive(:passed?).and_return(false)
    allow(Github::Status).to receive(:passed?).with("678912").and_return(true)
  end
  load_shared_commit_data
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
      },
    }.to_json
  end

  context "when the values are all valid" do
    let(:expected_response) do
      "Apply was deployed yesterday\n:nope: Merge pull request #1999 from moj/AA-1234\n" \
        ":nope: Merge pull request #1998 from moj/AA-421\n:yep: Merge pull request #1997 from moj/AA-666\n" \
        ":yep: Merge pull request #1996 from moj/AA-555\n:yep: Merge pull request #1995 from moj/AA-444\n" \
        "CFE was deployed 14 days ago\n:nope: Merge pull request #1999 from moj/AA-1234\n" \
        ":nope: Merge pull request #1998 from moj/AA-421\n:yep: Merge pull request #1997 from moj/AA-666\n" \
        ":yep: Merge pull request #1996 from moj/AA-555\n:yep: Merge pull request #1995 from moj/AA-444"
    end
    let(:channel) { "channel" }

    it "returns the expected message" do
      Timecop.travel(Date.new(2020, 4, 16)) do
        expect(message: user_input, channel:).to respond_with_slack_message(expected_response)
      end
    end

    it_behaves_like "the channel is invalid"
  end
end
