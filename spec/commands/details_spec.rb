require 'spec_helper'

describe SlackApplybot::Commands::Details, :vcr do

  let(:user_input) { "#{SlackRubyBot.config.user} #{app} details #{env}" }
  
  context 'when user requests details for a valid application and environment' do
    let(:app) { 'cfe' }
    let(:env) { 'staging' }
    let(:expected_response) { "`staging` details for `cfe`:```{\"build_date\"=>\"2020-03-20T13:59:40+0000\", \"build_tag\"=>\"app-ccf322d51b508fd16316d24593a44e9c887be281\", \"app_branch\"=>\"master\"}```" }

    it 'returns the expected message' do
    	expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
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
