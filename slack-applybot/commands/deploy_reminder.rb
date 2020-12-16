module SlackApplybot
  module Commands
    class DeployReminder < SlackRubyBot::Commands::Base
      scan(/^(\S*) has a pending production approval for master/) do |_client, data, match|
        result = OpenStruct.new(
          {
            channel: data.channel,
            channel_name: SendSlackMessage.new.conversations_info(channel: data.channel)['channel']['name'],
            github_name: match,
            proposal: "I want to look up #{match.flatten.first}, find a slack id and send them a message"
          }
        )
        SlackRubyBot::Client.logger.warn(result.to_json)
      end
    end
  end
end
