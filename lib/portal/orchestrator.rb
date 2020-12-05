module Portal
  class Orchestrator
    def initialize(user_array, channel)
      @user_array = user_array
      @channel = channel
    end

    def self.compose(user_array, channel)
      new(user_array, channel).compose
    end

    def compose
      build_name_list
      results = @user_list.map { |name| Portal::NameValidator.call(name) }
      if results.all?(true)
        script = build_success_script
        params = { channels: Portal::OutputChannel.is, content: script, filename: 'output.ldif' }
        SendSlackMessage.new.upload_file(params) if script.present?
        send_message_to_user unless Portal::OutputChannel.new(@channel).valid?
      else
        SendSlackMessage.new.generic(channel: @channel, as_user: true, text: build_error_script)
      end
    end

    private

    def send_message_to_user
      message = "Done, I have raised a request in the ##{ENV['USER_OUTPUT_CHANNEL']} channel"
      SendSlackMessage.new.generic(channel: @channel, as_user: true, text: message)
    end

    def build_name_list
      @user_list = @user_array.map { |user| Portal::Name.new(user) }
    end

    def build_error_script
      Portal::NameErrorMessage.call(@user_list)
    end

    def build_success_script
      Portal::GenerateScript.call(@user_list)
    end
  end
end
