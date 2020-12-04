require 'rspec'

describe SlackApplybot::Commands::Test2faValidation do
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
  let(:channel) { 'channel' }

  describe 'configure 2fa' do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa-start" }

    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to respond_with_slack_message
    end

    context 'when the user is not in a channel on the allowed list' do
      let(:channel) { 'dangerous' }
      let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end
  end

  describe 'validate 2fa' do
    context 'when the code is wrong do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-check 000000" }

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message('2FA not configured')
      end
    end

    context 'when the code is right do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-check 123456" }
      before { allow_any_instance_of(ROTP::TOTP).to receive(:verify).with('123456').and_return(true) }

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message('2FA successfully configured')
      end

      context 'when the user is not in a channel on the allowed list' do
        let(:channel) { 'dangerous' }
        let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

        it 'returns the expected message' do
          expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
        end
      end
    end
  end
end
