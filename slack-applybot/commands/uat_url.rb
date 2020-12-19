module SlackApplybot
  module Commands
    class UatUrl < SlackRubyBot::Commands::Base
      command(/uat (url|urls)/) do |client, data, match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        branch =  match['expression']
        ingresses = Kube::Ingresses.call('laa-apply-for-legalaid-uat')
        if branch.present?
          single_match = ingresses.find { |e| e.starts_with?(branch) }
          message_text = if single_match
                           "Branch <https://#{single_match}|#{branch}> is available"
                         else
                           "Sorry I can't find a branch for #{branch} I only have:\n#{display(ingresses)}"
                         end
        else
          message_text = "Apply UAT urls:\n#{display(ingresses)}"
        end
        client.say(channel: data.channel, text: message_text)
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
