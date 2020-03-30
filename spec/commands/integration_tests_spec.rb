require 'spec_helper'

describe SlackApplybot::Commands::IntegrationTests, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} run tests" }

  context 'when user requests a test run' do
    it 'starts typing and triggers the sidekiq job' do
      expect(StartIntegrationTestsWorker).to receive(:perform_async)
      expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to be_a Hash
    end
  end
end
