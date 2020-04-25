require 'spec_helper'

describe SlackRubyBot::Commands::Help, :vcr do
  let(:user_input) { "#{SlackRubyBot.config.user} help" }
  let(:expected_response) do
    "*Weather Bot* - This bot tells you the weather.\n"\
    "\n*Commands:*\n*clouds* - Tells you how many clouds there're above you."\
    "\n*command_without_description*\n*What's the weather in <city>?* - Tells you the weather in a <city>.\n"\
    "*LAA Apply Bot* - This bot assists the LAA Apply team to administer their applications\n"\
    "\n*Commands:*"\
    "\n*ages* - `@apply-bot ages`"\
    "\n*details* - `@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`"\
    "\n*run tests* - `@apply-bot run tests`"\
    "\n*uat urls* - `@apply-bot uat urls`"\
    "\n*uat url* - `@apply-bot uat url <branch> e.g. @apply-bot uat url ap-999`\n"\
    "\nFor full description of the command use: *help <command>*\n"
  end
  # TODO: find out why the ruby-slack-bot is inserting thw weather bot output into the test response!

  it 'returns the expected message' do
    expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
  end

  context 'when passed an explicit command' do
    let(:user_input) { "#{SlackRubyBot.config.user} help details" }
    let(:expected_response) do
      "*details* - `@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`\n"\
      "\nShows the ping details page for the selected application and non-uat environments, "\
      'e.g.  `@apply-bot apply details staging` or `@apply-bot cfe details production`'
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: 'channel').to respond_with_slack_message(expected_response)
    end
  end
end
