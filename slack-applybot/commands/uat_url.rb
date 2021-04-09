module SlackApplybot
  module Commands
    class UatUrl < SlackRubyBot::Commands::Base
      command 'uat' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        ingresses = Kube::Ingresses.call('laa-apply-for-legalaid-uat')
        message = case match['expression']&.downcase
                  when /^urls$/
                    "Apply UAT urls:\n#{display(ingresses)}"
                  when /^url/
                    branch = match['expression'].gsub(/url /, '')
                    single_match = ingresses.find { |e| e.starts_with?(branch) }
                    if single_match
                      "Branch <https://#{single_match}|#{branch}> is available"
                    else
                      "Sorry I can't find a branch for #{branch} I only have:\n#{display(ingresses)}"
                    end
                  else
                    "You called `uat` with `#{match['expression']}`. This is not supported."
                  end

        client.say(channel: data.channel, text: message)
      end

      class << self
        include ChannelValidity
        include UserCommand

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
