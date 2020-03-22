module SlackRubyBot
  module Commands
    class Help < Base
      command 'help' do |client, data, match|
        command = match[:expression]

        text = if command.present?
                 Support::Help.instance.command_full_desc(command)
               else
                 general_text
               end

        client.say(channel: data.channel, text: text)
      end

      class << self
        private

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
