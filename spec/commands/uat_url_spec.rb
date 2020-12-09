require 'spec_helper'

describe SlackApplybot::Commands::UatUrl, :vcr do
  before { allow(Kubectl).to receive(:uat_ingresses).and_return(expected_environments) }
  let(:expected_environments) { %w[ap-1234-test.fake.service.uk ap-4321-bad.fake.service.uk] }
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

  context 'when user requests all uat urls' do
    let(:user_input) { "#{SlackRubyBot.config.user} uat urls" }
    let(:expected_response) do
      "Apply UAT urls:\n"\
      "<https://ap-1234-test.fake.service.uk|ap-1234-test>\n"\
      '<https://ap-4321-bad.fake.service.uk|ap-4321-bad>'
    end
    let(:channel) { 'channel' }

    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
    end
    context 'when the user is not in a channel on the allowed list' do
      let(:channel) { 'dangerous' }
      let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end
  end

  context 'when user requests a specific branch' do
    let(:user_input) { "#{SlackRubyBot.config.user} uat url #{branch}" }
    let(:channel) { 'channel' }

    context 'that exists' do
      let(:branch) { 'ap-1234' }
      let(:expected_response) do
        'Branch <https://ap-1234-test.fake.service.uk|ap-1234> is available'
      end

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end

    context 'that does not exist' do
      let(:branch) { 'ap-666' }
      let(:expected_response) do
        "Sorry I can't find a branch for #{branch} I only have:\n"\
        "<https://ap-1234-test.fake.service.uk|ap-1234-test>\n"\
        '<https://ap-4321-bad.fake.service.uk|ap-4321-bad>'
      end

      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
      end
    end

    context 'when the user is not in a channel on the allowed list' do
      let(:channel) { 'dangerous' }
      let(:branch) { 'ap-1234' }
      let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

      it 'returns the expected message' do
        Timecop.travel(Date.new(2020, 4, 16)) do
          expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
        end
      end
    end
  end
end
