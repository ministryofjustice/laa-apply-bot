require "spec_helper"

describe SlackApplybot::Commands::Helm, :vcr do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    allow(Helm::List).to receive(:call).with("hmrc").and_return("ap3456\nap4567")
    allow(Helm::List).to receive(:call).with("apply").and_return("ap1234\nap2345")
    allow(Helm::Tidy).to receive(:call).with("hmrc").and_return(tidy_hmrc_return)
    allow(Helm::Tidy).to receive(:call).with("apply").and_return(tidy_return)
  end

  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
      },
    }.to_json
  end
  let(:tidy_return) do
    ":nope: apply-ap-2345-second-name - branch deleted - you can run the following locally  - " \
      "`helm delete apply-ap-2345-second-name --dry-run`\n" \
      "1 branch retained"
  end
  let(:tidy_hmrc_return) do
    ":nope: ap-2345-second-name - branch deleted - you can run the following locally  - " \
      "`helm delete ap-2345-second-name --dry-run`\n" \
      "1 branch retained"
  end
  let(:user_input) { "#{SlackRubyBot.config.user} helm #{command}" }
  let(:command) { "" }

  it_behaves_like "the channel is invalid"
  context "when the channel is valid" do
    let(:channel) { "channel" }

    context "when the command is missing" do
      let(:missing_command_response) { SlackRubyBot::Commands::Support::Help.instance.command_full_desc("helm") }

      it "returns the expected message" do
        expect(message: user_input, channel:).to respond_with_slack_message(missing_command_response)
      end
    end

    context "when the command is unsupported" do
      let(:command) { "destroy" }
      let(:unsupported_command_response) { "You called `helm` with `destroy`. This is not supported." }

      it "returns the expected message" do
        expect(message: user_input, channel:).to respond_with_slack_message(unsupported_command_response)
      end
    end

    context "when the command is list" do
      let(:command) { "list" }
      let(:command_response) { "ap1234\nap2345" }

      it "returns the expected message" do
        expect(message: user_input, channel:).to respond_with_slack_message(command_response)
      end

      context "and has a context listed" do
        let(:command) { "list hmrc" }
        let(:command_response) { "ap3456\nap4567" }

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(command_response)
        end
      end

      context "and has an invalid context listed" do
        let(:command) { "list portal" }
        let(:command_response) { "`portal` is not a valid context, you can only use `apply, cfe, hmrc, and lfa`" }

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(command_response)
        end
      end
    end

    context "when the command is tidy" do
      let(:command) { "tidy" }

      it "returns the expected message" do
        expect(message: user_input, channel:).to respond_with_slack_message(tidy_return)
      end

      context "and has a context listed" do
        let(:command) { "tidy hmrc" }
        let(:command_response) { "ap3456\nap4567" }

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(tidy_hmrc_return)
        end
      end

      context "and has an invalid context listed" do
        let(:command) { "tidy portal" }
        let(:command_response) { "`portal` is not a valid context, you can only use `apply, cfe, hmrc, and lfa`" }

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(command_response)
        end
      end
    end

    context "when the command is delete" do
      context "but no release or OTP is provided" do
        let(:command) { "delete" }
        let(:command_response) do
          "Unable to delete - insufficient data, please call as `helm delete name-of-release 000000`"
        end

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(command_response)
        end
      end

      context "and no OTP is provided" do
        let(:command) { "delete ap1234" }
        let(:command_response) { "OTP password not provided, please call as `helm delete name-of-release 000000`" }

        it "returns the expected message" do
          expect(message: user_input, channel:).to respond_with_slack_message(command_response)
        end
      end

      context "when OTP is provided" do
        before do
          allow(User).to receive(:find_or_create_by).and_return(user)
          allow(ROTP::TOTP).to receive(:new).and_return(rotp)
          allow(rotp).to receive(:verify).with("123456").and_return(valid_token?)
          allow(::Helm::Delete).to receive(:call).with(context, "ap1234").and_return(true)
        end

        let(:user) { FactoryBot.create :user, encrypted_2fa_secret: encrypted_secret }
        let(:rotp) { instance_double(ROTP::TOTP) }
        let(:encrypted_secret) { Encryption::Service.encrypt("secret") }
        let(:command) { "delete ap1234 123456" }
        let(:context) { "apply" }

        context "and it is correct" do
          let(:command_response) { "ap1234 deleted" }
          let(:valid_token?) { true }

          it "returns the expected message" do
            expect(message: user_input, channel:).to respond_with_slack_message(command_response)
          end

          context "and a different context is provided" do
            let(:command) { "delete lfa ap1234 123456" }
            let(:context) { "lfa" }

            it "returns the expected message" do
              expect(message: user_input, channel:).to respond_with_slack_message(command_response)
            end
          end
        end

        context "but it is incorrect" do
          let(:command_response) { "OTP password did not match, please check your authenticator app" }
          let(:valid_token?) { false }

          it "returns the expected message" do
            expect(message: user_input, channel:).to respond_with_slack_message(command_response)
          end
        end
      end
    end
  end
end
