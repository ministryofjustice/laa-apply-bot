require "rspec"

RSpec.describe SlackApplybot::Commands::TwoFactorAuth do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.open\z}).to_return(status: 200, body: user_body)
  end

  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
        is_im: is_direct_message?,
      },
    }.to_json
  end
  let(:user_body) do
    {
      'ok': true,
      'channel': {
        id: "A0000B1CDEF",
      },
    }.to_json
  end
  let(:channel) { "channel" }
  let(:is_direct_message?) { false }
  let(:command) { "setup" }
  let(:user_input) { "#{SlackRubyBot.config.user} 2fa #{command}" }
  let(:expected_hash) do
    {
      channel:,
      text: expected_message,
    }
  end
  let!(:client) { SlackRubyBot::App.new.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  let(:params) { Hashie::Mash.new(text: user_input, channel:, user: "user") }

  describe "#setup" do
    let(:command) { "setup" }

    context "when the user is in a direct message channel" do
      let(:is_direct_message?) { true }

      context "when the user has not connected github" do
        let(:dm_hash) do
          { channel: "A0000B1CDEF", text: "You need to link your github account before you can setup 2FA" }
        end

        it "starts typing, sends a DM and then replies in the public channel" do
          expect(client).to receive(:typing)
          expect(client).to receive(:say).with(dm_hash)
          message_hook.call(client, params)
        end
      end

      context "when the user has connected github" do
        let(:user) { FactoryBot.create :user, github_id: "123456" }
        let(:ssm) { instance_double("SendSlackMessage") }

        before do
          allow(User).to receive(:find_or_create_by).and_return(user)
          allow(ssm).to receive(:upload_file).and_return(true)
          allow(ssm).to receive(:conversations_info).and_return(JSON.parse(expected_body))
          allow(SendSlackMessage).to receive(:new).and_return(ssm)
        end

        it "starts typing, sends a DM and then replies in the public channel" do
          expect(client).to receive(:typing)
          expect(ssm).to receive(:upload_file)
          message_hook.call(client, params)
        end
      end
    end

    context "when the user is in a public, valid channel" do
      let(:expected_message) { "I've sent you a DM, we probably shouldn't be talking about this in public!" }
      let(:dm_hash) do
        { channel: "A0000B1CDEF", text: "You need to link your github account before you can setup 2FA" }
      end

      it "responds with a warning message" do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        expect(client).to receive(:say).with(dm_hash)
        message_hook.call(client, params)
      end
    end
  end

  describe "#confirm" do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa #{command} #{otp_code}" }
    let(:command) { "confirm" }

    context "when the message is a DM to the bot" do
      let(:channel) { "A0000B1CDEF" }
      let(:is_direct_message?) { true }

      context "but no OTP is provided" do
        let(:otp_code) { "" }
        let(:expected_message) do
          "OTP password not provided, please call as `2fa confirm 000000`"
        end

        it "returns the expected message" do
          expect(client).to receive(:typing)
          expect(client).to receive(:say).with(expected_hash)
          message_hook.call(client, params)
        end
      end

      context "when OTP is provided" do
        before do
          allow(User).to receive(:find_or_create_by).and_return(user)
          allow(ROTP::TOTP).to receive(:new).and_return(rotp)
          allow(rotp).to receive(:verify).with("123456").and_return(valid_token?)
          allow(::Helm::Delete).to receive(:call).with("ap1234").and_return(true)
        end

        let(:user) { FactoryBot.create :user, encrypted_2fa_secret: encrypted_secret }
        let(:rotp) { instance_double(ROTP::TOTP) }
        let(:encrypted_secret) { Encryption::Service.encrypt("secret") }
        let(:otp_code) { "123456" }

        context "and it is correct" do
          let(:expected_message) { "OTP has been successfully configured" }
          let(:valid_token?) { true }

          it "returns the expected message" do
            expect(client).to receive(:typing)
            expect(client).to receive(:say).with(expected_hash)
            message_hook.call(client, params)
          end
        end

        context "but it is incorrect" do
          let(:expected_message) { "OTP password did not match, please check your authenticator app" }
          let(:valid_token?) { false }

          it "returns the expected message" do
            expect(client).to receive(:typing)
            expect(client).to receive(:say).with(expected_hash)
            message_hook.call(client, params)
          end
        end
      end
    end

    context "when the message is in a public, allowed channel" do
      let(:expected_message) { "I've sent you a DM, we probably shouldn't be talking about this in public!" }
      let(:otp_code) { "" }
      let(:dm_hash) do
        { channel: "A0000B1CDEF", text: "OTP password not provided, please call as `2fa confirm 000000`" }
      end

      it "starts typing, sends a DM and then replies in the public channel" do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        expect(client).to receive(:say).with(dm_hash)
        message_hook.call(client, params)
      end
    end
  end

  context "when the command is unsupported" do
    let(:command) { "cancel" }
    let(:expected_message) { "You called `2fa` with `cancel`. This is not supported." }

    it "returns the expected message" do
      expect(client).to receive(:typing)
      expect(client).to receive(:say).with(expected_hash)
      message_hook.call(client, params)
    end
  end

  it_behaves_like "the channel is invalid"
end
