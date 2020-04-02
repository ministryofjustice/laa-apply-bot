module SlackApplybot
  module Commands
    class Details < SlackRubyBot::Commands::Base
      command 'apply', 'cfe', /details/ do |client, data, match|
        return unless match['expression'].include?('details')

        app = match['command'].downcase
        env = match['expression'].sub('details', '').strip.downcase
        return unless env.split(/,\s|\s/).count.eql?(1)
        return unless SlackApplybot::Environment.valid?(app, env)

        environment = Environment.new(app, env)

        message_text = "`#{environment.name}` details for `#{app}`:```#{environment.ping_data}```"
        client.say(channel: data.channel, text: message_text)
      end
    end
  end
end
