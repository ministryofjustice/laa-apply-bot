module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      command 'helm' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        message = case match['expression']
                  when /^list/, /^tidy/
                    process_command(match)
                  when /^delete/
                    process_delete(match)
                  when nil
                    SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm')
                  else
                    "You called `helm` with `#{match['expression']}`. This is not supported."
                  end

        client.say(channel: data.channel, text: message)
      end

      class << self
        VALID_CONTEXTS = %w[apply hmrc].freeze
        include ChannelValidity
        include TwoFactorAuthShared
        include UserCommand

        def process_delete(match)
          parts = match['expression'].split - ['delete']
          if parts.empty?
            'Unable to delete - insufficient data, please call as `helm delete name-of-release 000000`'
          elsif parts.count.eql?(1)
            'OTP password not provided, please call as `helm delete name-of-release 000000`'
          elsif validate_otp_part(parts[1])
            ::Helm::Delete.call(parts[0]) ? "#{parts[0]} deleted" : 'Unable to delete'
          else
            'OTP password did not match, please check your authenticator app'
          end
        end

        def process_command(match)
          parts = match['expression'].split
          command = parts[0]
          context = parts[1] || 'apply'
          if validate_context(context)
            "::Helm::#{command.capitalize}".constantize.call(context)
          else
            "`#{context}` is not a valid context, you can only use `#{VALID_CONTEXTS.join(',')}`"
          end
        end

        def validate_context(name)
          VALID_CONTEXTS.include?(name.downcase)
        end
      end
    end
  end
end
