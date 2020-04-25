require 'spec_helper'

describe SlackApplybot::Commands::UatUrl, :vcr do
  before { allow(Kubectl).to receive(:uat_ingresses).and_return(expected_environments) }
  let(:expected_environments) { %w[ap-1234-test.fake.service.uk ap-4321-bad.fake.service.uk] }

  context 'when user requests all uat urls' do
    let(:user_input) { "#{SlackRubyBot.config.user} uat urls" }
    let(:expected_response) do
      "Apply UAT urls:\n"\
      "<ap-1234-test.fake.service.uk|ap-1234-test>\n"\
      '<ap-4321-bad.fake.service.uk|ap-4321-bad>'
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
    end
  end

  context 'when user requests a specific branch' do
    let(:user_input) { "#{SlackRubyBot.config.user} uat url #{branch}" }

    context 'that exists' do
      let(:branch) { 'ap-1234' }
      let(:expected_response) do
        'Branch <ap-1234-test.fake.service.uk|ap-1234> is available'
      end

      it 'returns the expected message' do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
      end
    end

    context 'that does not exist' do
      let(:branch) { 'ap-666' }
      let(:expected_response) do
        "Sorry I can't find a branch for #{branch} I only have:\n"\
        "<ap-1234-test.fake.service.uk|ap-1234-test>\n"\
        '<ap-4321-bad.fake.service.uk|ap-4321-bad>'
      end

      it 'returns the expected message' do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
      end
    end
  end
end
