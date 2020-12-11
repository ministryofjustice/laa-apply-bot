module Portal
  class Orchestrator
    def initialize(user_array, data)
      @user_array = user_array
      @channel = data['channel']
      @user = data['user']
    end

    def self.compose(user_array, data)
      new(user_array, data).compose
    end

    def compose
      build_name_list
      results = @user_list.map { |name| Portal::NameValidator.call(name) }
      if results.all?(true)
        script = build_success_script
        params = params(script)
        SendSlackMessage.new.upload_file(params) if script.present?
        send_message_to_user unless Portal::OutputChannel.new(@channel).valid?
      else
        SendSlackMessage.new.generic(channel: @channel, as_user: true, text: build_error_script)
      end
    end

    private

    def params(script)
      { channels: Portal::OutputChannel.is, content: script, filename: 'output.ldif', initial_comment: notify_text }
    end

    def notify_text
      '<!here> can you add the following users? ' \
      "<@#{@user}> has raised the request and the apply service is ready for them"
    end

    def send_message_to_user
      message = "Done, I have raised a request in the ##{Portal::OutputChannel.display_name} channel"
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
