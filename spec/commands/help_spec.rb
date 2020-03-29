require 'spec_helper'

describe SlackRubyBot::Commands::Help, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} help" }

  let(:expected_response) { { channel: 'channel', message: 'rubybot help' } }

  it 'returns the expected message' do
    expect(message: user_input, channel: 'channel').to eql expected_response
  end
end
