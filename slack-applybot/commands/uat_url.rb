module SlackApplybot
  module Commands
    class UatUrl < SlackRubyBot::Commands::Base
      command 'uat urls' do |client, data, _match|
        @client = client
        @data = data
        if channel_is_valid?
          ingresses = Kubectl.uat_ingresses
          message_text = "Apply UAT urls:\n#{display(ingresses)}"
          client.say(channel: data.channel, text: message_text)
        else
          send_fail
        end
      end

      command 'uat url' do |client, data, match|
        @client = client
        @data = data
        if channel_is_valid?
          branch =  match['expression']
          ingresses = Kubectl.uat_ingresses
          single_match = ingresses.find { |e| e.starts_with?(branch) }
          message_text = if single_match
                           "Branch <https://#{single_match}|#{branch}> is available"
                         else
                           "Sorry I can't find a branch for #{branch} I only have:\n#{display(ingresses)}"
                         end
          client.say(channel: data.channel, text: message_text)
        else
          send_fail
        end
      end

      class << self
        include ChannelValidity

        private

        def display(ingresses)
          ingresses.map do |ingress|
            "<https://#{ingress}|#{ingress.gsub('-applyforlegalaid-uat', '').split('.').first}>"
          end.join("\n")
        end
      end
    end
  end
end
