module SlackApplybot
  module Commands
    class Details < SlackRubyBot::Commands::Base
      command 'apply', 'cfe', /details/ do |client, data, match|
        @client = client
        @data = data
        if channel_is_valid?
          app = match['command'].downcase
          env = match['expression'].sub('details', '').strip.downcase
          return unless env.split(/,\s|\s/).count.eql?(1)

          environment = "#{app.humanize}Instance".constantize.new(env)

          message_text = "`#{environment.name}` details for `#{app}`:```#{environment.ping_data}```"
          client.say(channel: data.channel, text: message_text)
        else
          send_fail
        end
      end

      class << self
        include ChannelValidity
      end
    end
  end
end
