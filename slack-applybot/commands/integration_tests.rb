module SlackApplybot
  module Commands
    class IntegrationTests < SlackRubyBot::Commands::Base
      command 'run tests' do |client, data, _match|
        @client = client
        @data = data
        if channel_is_valid?
          client.typing(channel: data.channel)
          TestRunStartWorker.perform_async(data)
        else
          send_fail
        end
      end

      class << self
        include ChannelValidity
      end
    end
  end
end
