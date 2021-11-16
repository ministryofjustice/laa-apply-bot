module SlackApplybot
  module Commands
    class AddUser < SlackRubyBot::Commands::Base
      command(/add (user|users)/) do |client, data, match|
        client.typing(channel: data.channel)
        Portal::UserRequester.initiate(match['expression'], data.channel)
      end
    end
  end
end
