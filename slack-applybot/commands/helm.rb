module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      command 'helm' do |client, data, match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        # releases = JSON.parse(`helm list -o json`)
        # releases.map { |release| release['name'] }

        message = SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm') unless match['expression']
        client.say(channel: data.channel, text: message)
      end

      class << self
        include ChannelValidity
      end
    end
  end
end
