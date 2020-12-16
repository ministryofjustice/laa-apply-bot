module SlackApplybot
  module Commands
    class DeployReminder < SlackRubyBot::Commands::Base
      scan(/^((?!user|help|details|tests|uat|ages|hi|2fa).)*$/) do |_client, data, _match|
        result = OpenStruct.new(
          {
            channel: data.channel,
            channel_name: SendSlackMessage.new.conversations_info(channel: data.channel)['channel']['name'],
            blocks: data.blocks
          }
        )
        SlackRubyBot::Client.logger.warn(result.to_json)
      end
    end
  end
end
