module SlackApplybot
  module Commands
    class DeployReminder < SlackRubyBot::Commands::Base
      attachment(/(\S*) has a pending (\w*) production approval for master/) do |_client, data, match|
        result = OpenStruct.new(
          {
            channel: data.channel,
            channel_name: SendSlackMessage.new.conversations_info(channel: data.channel)['channel']['name'],
            attachment: data.attachments,
            match: match,
            proposal: "Find slack id for #{match[0]} and remind them to deploy #{match[1]} to production"
          }
        )
        SlackRubyBot::Client.logger.warn(result.to_json)
      end
    end
  end
end
