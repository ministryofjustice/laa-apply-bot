require 'http'

module SlackApplybot
  module Commands
    class Details < SlackRubyBot::Commands::Base
    	command 'apply', 'cfe', /details/ do |client, data, match|
        app = match['command']
    		return unless match['expression'].include?('details')
    		env = match['expression'].sub('details', '').strip
    		return unless env.split(/,\s|\s/).count.eql?(1)
        return unless SlackApplybot::Environment.valid?(app, env)

        environment = Environment.new(app, env)
        built_uri = environment.ping_page
        response = HTTP.get(built_uri)
        json = JSON.parse(response.body)

        client.say(channel: data.channel, text: "`#{environment.name}` details for `#{app}`:```#{json}```")
	    end
    end
  end
end
