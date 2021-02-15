require 'spec_helper'

describe SlackApplybot::Commands::Helm, :vcr do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    allow(Helm::List).to receive(:call).and_return("ap1234\nap2345")
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel
      }
    }.to_json
  end
  let(:user_input) { "#{SlackRubyBot.config.user} helm #{command}" }
  let(:command) { '' }

  it_behaves_like 'the channel is invalid'
  context 'when the channel is valid' do
    let(:channel) { 'channel' }

    context 'when the command is missing' do
      let(:missing_command_response) { SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm') }
      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(missing_command_response)
      end
    end

    context 'when the command is unsupported' do
      let(:command) { 'delete' }
      let(:unsupported_command_response) { 'You called `helm` with `delete`. This is not supported.' }
      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(unsupported_command_response)
      end
    end

    context 'when the command is list' do
      let(:command) { 'list' }
      let(:command_response) { "ap1234\nap2345" }
      it 'returns the expected message' do
        expect(message: user_input, channel: channel).to respond_with_slack_message(command_response)
      end
    end
  end
end
