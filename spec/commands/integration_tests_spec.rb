require 'spec_helper'

describe SlackApplybot::Commands::IntegrationTests, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} run tests" }

  context 'when user requests a test run' do
    it 'starts typing' do
      expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to be_a Hash
    end

    xit 'triggers the sidekiq job' do
      expect { SlackRubyBot::Hooks::Message.new(message: user_input, channel: 'channel') }
        .to change(MonitorTestRunWorker.jobs, :size).by(1)
    end
  end
end
