require 'spec_helper'

describe SlackApplybot::Commands::Details, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} #{app} details #{env}" }

  context 'when user requests details for a valid application and environment' do
    let(:app) { 'cfe' }
    let(:env) { 'staging' }
    let(:expected_response) do
      key = '`staging` details for `cfe`'
      build = 'app-0b68f9cfec011cd7188d027cb3e02a7c13ec2bfa'
      value = "{\"build_date\"=>\"2020-04-01T18:10:11+0000\", \"build_tag\"=>\"#{build}\", \"app_branch\"=>\"master\"}"
      "#{key}:```#{value}```"
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
    end

    context 'in non-lower case' do
      let(:app) { 'Cfe' }

      it 'returns the expected message' do
        expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
      end
    end
  end

  context 'when user requests valid environment details for an invalid application' do
    let(:app) { 'simon' }
    let(:env) { 'staging' }
    let(:expected_response) { "Sorry <@user>, I don't understand that command!" }

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
    end
  end
end
