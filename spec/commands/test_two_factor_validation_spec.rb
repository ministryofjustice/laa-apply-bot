require 'rspec'

describe SlackApplybot::Commands::TestTwoFactorValidation do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.open\z}).to_return(status: 200, body: user_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
        is_im: is_direct_message?
      }
    }.to_json
  end
  let(:user_body) do
    {
      'ok': true,
      'channel': {
        id: 'A0000B1CDEF'
      }
    }.to_json
  end
  let(:channel) { 'channel' }
  let(:is_direct_message?) { false }

  describe '#2fa-start' do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa-start" }
    let!(:client) { SlackRubyBot::App.new.send(:client) }
    let(:message_hook) { SlackRubyBot::Hooks::Message.new }
    let(:params) { Hashie::Mash.new(text: user_input, channel: channel, user: 'user') }

    context 'the user is in a direct message channel' do
      let(:is_direct_message?) { true }

      it 'starts typing' do
        expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
      end
    end

    context 'the user is in a public, valid channel' do
      let(:expected_response) { "I've sent you a DM, we probably shouldn't be talking about this in public!" }
      let(:expected_hash) do
        { channel: channel, text: expected_response }
      end

      it 'responds with a warning message' do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        message_hook.call(client, params)
      end
    end

    it_behaves_like 'the channel is invalid'
  end

  describe '#2fa-check' do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa-check" }
    let!(:client) { SlackRubyBot::App.new.send(:client) }
    let(:message_hook) { SlackRubyBot::Hooks::Message.new }
    let(:params) { Hashie::Mash.new(text: user_input, channel: channel, user: 'user') }

    context 'the user is in a public, valid channel' do
      let(:expected_response) { "I've sent you a DM, we probably shouldn't be talking about this in public!" }
      let(:public_hash) { { channel: channel, text: expected_response } }
      let(:direct_message_hash) { { channel: 'A0000B1CDEF', text: '2FA not enabled' } }

      it 'responds with a warning message' do
        expect(client).to receive(:say).with(public_hash)
        expect(client).to receive(:say).with(direct_message_hash)
        message_hook.call(client, params)
      end
    end

    it_behaves_like 'the channel is invalid'
  end

  describe '#2fa-validate' do
    context 'when the code is wrong do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-validate 000000" }

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message('2FA not configured')
      end
    end

    context 'when the code is right do' do
      let(:user_input) { "#{SlackRubyBot.config.user} 2fa-validate 123456" }
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
