module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      command 'helm' do |client, data, _match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        # releases = JSON.parse(`helm list -o json`)
        # releases.map { |release| release['name'] }
        client.say(channel: data.channel, text: 'not yet implemented')
      end

      class << self
        include ChannelValidity
      end
    end
  end
end
