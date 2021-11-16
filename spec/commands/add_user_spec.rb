require 'spec_helper'

describe SlackApplybot::Commands::AddUser, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} #{command} #{user_csv}" }
  let(:user_csv) { 'test.user' }

  context 'when command is `add user`' do
    before do
      class_double(Portal::UserRequester).as_stubbed_const
      class_double(Portal::NameValidator, call: true).as_stubbed_const
    end
    let(:command) { 'add user' }

    it 'calls the user requester and sends a `typing` message to the channel' do
      expect(Portal::UserRequester).to receive(:initiate)
      expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
    end
  end
end
