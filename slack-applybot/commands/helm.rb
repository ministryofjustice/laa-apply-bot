module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      command 'helm' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        message = case match['expression']
                  when /^tidy/
                    ::Helm::Tidy.call(match, data.channel)
                  when /^list/
                    process_command(match)
                  when nil
                    SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm')
                  else
                    "You called `helm` with `#{match['expression']}`. This is not supported."
                  end
        client.say(channel: data.channel, text: message) unless message.nil?
      end

      class << self
        VALID_CONTEXTS = %w[apply cfe hmrc lfa].freeze
        include ChannelValidity
        include UserCommand

        def process_command(match)
          parts = match['expression'].split
          command = parts[0]
          context = parts[1] || 'apply'
          if validate_context(context)
            "::Helm::#{command.capitalize}".constantize.call(context)
          else
            "`#{context}` is not a valid context, you can only use `#{VALID_CONTEXTS.to_sentence}`"
          end
        end

        def validate_context(name)
          VALID_CONTEXTS.include?(name.downcase)
        end
      end
    end
  end
end
