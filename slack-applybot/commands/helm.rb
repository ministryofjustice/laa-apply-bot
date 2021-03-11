module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      command 'helm' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        message = case match['expression']
                  when 'list'
                    result = "::Helm::#{match['expression'].capitalize}".constantize.call
                    "```#{result}```"
                  when 'tidy'
                    "::Helm::#{match['expression'].capitalize}".constantize.call
                  when nil
                    SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm')
                  else
                    "You called `helm` with `#{match['expression']}`. This is not supported."
                  end

        client.say(channel: data.channel, text: message)
      end

      class << self
        include ChannelValidity
        include UserCommand
      end
    end
  end
end
