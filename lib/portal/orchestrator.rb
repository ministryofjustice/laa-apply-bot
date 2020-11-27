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
        script = build_script
        params = { channels: @channel, content: script, filename: 'output.ldif' }
        SendSlackMessage.new.upload_file(params) if script.present?
      else
        SendSlackMessage.new.generic(channel: @channel, as_user: true, text: build_name_errors.chomp)
      end
    end

    private

    def build_name_errors
      result = ''
      @user_list.each do |name|
        result += good_name(name) if name.errors.nil?
        result += bad_name(name) if name.errors.present?
      end
      result
    end

    def good_name(name)
      "*#{name.display_name}* :yep:\n"
    end

    def bad_name(name)
      "*#{name.display_name}* :nope: #{name.errors}\n"
    end

    def build_name_list
      @user_list = @user_array.map { |user| Portal::Name.new(user) }
    end

    def build_script
      Portal::GenerateScript.call(@user_list)
    end
  end
end
