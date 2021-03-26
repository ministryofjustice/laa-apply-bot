module SlackApplybot
  module Commands
    class Github < SlackRubyBot::Commands::Base
      command 'github' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        client.typing(channel: data.channel)
        message = case match['expression']&.downcase
                  when /^link/
                    process_link_request(match)
                  when nil
                    SlackRubyBot::Commands::Support::Help.instance.command_full_desc('github')
                  else
                    "You called `github` with `#{match['expression']}`. This is not supported."
                  end
        client.say(channel: data.channel, text: message) if message
      end

      class << self
        include ChannelValidity
        include UserCommand

        def process_link_request(match)
          parts = match['expression'].split - ['link']
          if parts.empty?
            'Github ID not provided, please call as `github link <github_user_name>`'
          elsif link_account(parts[0])
            'Github link successfully configured'
          else
            'This github user is not in the correct team, please request access'
          end
        end

        def link_account(github_name)
          user.update(github_id: github_name) if github_name_in_group?(github_name)
          user.github_id.present?
        end

        def github_name_in_group?(github_name)
          ::Github::TeamMembership.member?(github_name, 'laa-apply-for-legal-aid')
        end
      end
    end
  end
end
