module SlackRubyBot
  module Commands
    class Help < Base
      command "help" do |client, data, match|
        @client = client
        @data = data
        @command = match[:expression]

        text = if channel_is_valid?
                 text_when_channel_is_public
               else
                 text_when_channel_is_shared
               end
        client.say(channel: data.channel, text:)
      end

      class << self
        include ChannelValidity

      private

        def text_when_channel_is_public
          if @command.present?
            Support::Help.instance.command_full_desc(@command)
          else
            general_text
          end
        end

        def text_when_channel_is_shared
          Support::Help.instance.command_full_desc("add users")
        end

        def general_text
          bot_desc = Support::Help.instance.bot_desc_and_commands
          <<~TEXT
            #{bot_desc.join("\n")}

            For full description of the command use: *help <command>*
          TEXT
        end
      end
    end
  end
end
