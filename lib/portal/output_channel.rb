module Portal
  class OutputChannel
    def initialize(current_channel)
      @current_channel = current_channel
    end

    def valid?
      channel_name = SendSlackMessage.new.conversations_info(channel: @current_channel)["channel"]["name"]
      channel_name.eql?(ENV["USER_OUTPUT_CHANNEL"])
    end

    def self.is
      ENV["USER_OUTPUT_CHANNEL"]
    end

    def self.display_name
      SendSlackMessage.new.conversations_info(channel: is)["channel"]["name"]
    end
  end
end
