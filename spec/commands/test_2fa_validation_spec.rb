require 'rspec'

describe SlackApplybot::Commands::Test2faValidation do
  describe 'configure 2fa' do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa-start" }

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message
    end
  end

  describe 'validate 2fa' do
    context 'when the code is wrong do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-check 000000" }

      it 'returns the expected message' do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message('2FA not configured')
      end
    end

    context 'when the code is right do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-check 123456" }
      before { allow_any_instance_of(ROTP::TOTP).to receive(:verify).with('123456').and_return(true) }

      it 'returns the expected message' do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message('2FA successfully configured')
      end
    end
  end
end
