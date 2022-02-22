module SlackApplybot
  module Commands
    class IntegrationTests < SlackRubyBot::Commands::Base
      command "run tests" do |client, data, _match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        client.typing(channel: data.channel)
        Worker::TestRunStart.perform_async(data)
      end

      class << self
        include ChannelValidity
      end
    end
  end
end
