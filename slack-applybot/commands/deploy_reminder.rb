module SlackApplybot
  module Commands
    class DeployReminder < SlackRubyBot::Commands::Base
      def self.app_name(match)
        match[2].present? ? match[2] : 'Apply'
      end

      attachment(/(\S*) has a pending ?(\S*)? production approval for master/) do |_client, data, match|
        result = OpenStruct.new(
          {
            channel: data.channel,
            channel_name: SendSlackMessage.new.conversations_info(channel: data.channel)['channel']['name'],
            proposal: "Find slack id for #{match[1]} and remind them to deploy #{app_name(match)} to production"
          }
        )
        SlackRubyBot::Client.logger.warn(result.to_json)
      end
    end
  end
end
