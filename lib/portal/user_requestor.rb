module Portal
  class UserRequester
    def initialize(raw_name_data, channel)
      @collated_names = Portal::Names::Collator.new(raw_name_data)
      @channel = channel
    end

    def self.initiate(raw_name_data, channel)
      new(raw_name_data, channel).initiate
    end

    def initiate
      send_failure_alert if names.unmatched.present?
      send_success_message if names.matched.present?
    end

    private

    def names
      @names ||= @collated_names
    end

    def send_success_message
      script = Portal::GenerateScript.call(names.matched)
      matched_blocks = Portal::Messages::Success.call(script)
      SendSlackMessage.new.generic(channel: @channel, as_user: true, blocks: matched_blocks)
    end

    def send_failure_alert
      unmatched_blocks = Portal::Messages::Failure.call(names.unmatched.map(&:display_name))
      SendSlackMessage.new.generic(channel: @channel, as_user: true, blocks: unmatched_blocks)
    end
  end
end
