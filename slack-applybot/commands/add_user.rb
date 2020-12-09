module SlackApplybot
  module Commands
    class AddUser < SlackRubyBot::Commands::Base
      command(/add (user|users)/) do |client, data, match|
        client.typing(channel: data.channel)
        users_to_add = match['expression'].split(',').map(&:strip).map(&:upcase)

        Portal::Orchestrator.compose(users_to_add, data)
      end
    end
  end
end
