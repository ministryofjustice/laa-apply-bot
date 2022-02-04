require "spec_helper"

describe SlackApplybot::Commands::Github, :vcr do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    allow(::Github::TeamMembership).to receive(:member?).and_return(false)
    allow(::Github::TeamMembership).to receive(:member?).with("good_user", "laa-apply-for-legal-aid").and_return(member)
  end

  let(:user_input) { "#{SlackRubyBot.config.user} github #{command} #{github_id}" }
  let(:command) { "" }
  let(:github_id) { nil }
  let(:member) { true }
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
      },
    }.to_json
  end
  let!(:client) { SlackRubyBot::App.new.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  let(:params) { Hashie::Mash.new(text: user_input, channel:, user: "user") }
  let(:expected_hash) { { channel:, text: expected_message } }

  it_behaves_like "the channel is invalid"

  context "when the channel is valid" do
    let(:channel) { "channel" }

    context "when the command is missing" do
      let(:expected_message) { SlackRubyBot::Commands::Support::Help.instance.command_full_desc("github") }

      it "returns the expected message" do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        message_hook.call(client, params)
      end
    end

    context "when the command is unsupported" do
      let(:command) { "delete" }
      let(:expected_message) { "You called `github` with `delete`. This is not supported." }

      it "returns the expected message" do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        message_hook.call(client, params)
      end
    end

    context "when the command is correct" do
      let(:command) { "link" }

      context "when a no github ID is provided" do
        let(:expected_message) { "Github ID not provided, please call as `github link <github_user_name>`" }

        it "returns the expected message" do
          expect(client).to receive(:typing)
          expect(client).to receive(:say).with(expected_hash)
          message_hook.call(client, params)
        end
      end

      context "when a valid github ID is provided" do
        let(:github_id) { "good_user" }
        let(:expected_message) { "Github link successfully configured" }

        it "returns the expected message" do
          expect(client).to receive(:typing)
          expect(client).to receive(:say).with(expected_hash)
          message_hook.call(client, params)
        end
      end

      context "when an invalid github ID is provided" do
        let(:github_id) { "bad_user" }
        let(:expected_message) { "This github user is not in the correct team, please request access" }

        it "returns the expected message" do
          expect(client).to receive(:typing)
          expect(client).to receive(:say).with(expected_hash)
          message_hook.call(client, params)
        end
      end
    end
  end
end
