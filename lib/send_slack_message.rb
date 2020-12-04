class SendSlackMessage
  def initialize
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end
    check_connection
  end

  def update(params)
    # params = { ts: '0000000000.000000', channel: data['channel'], as_user: true, text: 'message_text' }
    client.chat_update(params)
  end

  def generic(params)
    # params = { channel: data['channel'], as_user: true, text: 'message_text' }
    client.chat_postMessage(params)
  end

  def upload_file(params)
    # params = { channels: data['channel'], content: 'line%20one%0Aafter%20new_line', filename: 'output.ldif' }
    client.files_upload(params)
  end

  def conversations_info(channel_id)
    client.conversations_info(channel_id)
  end

  def self.find_user(user_id)
    new.user(user_id)
  end

  def user(user_id)
    client.users_info(user: user_id)&.user
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def check_connection
    client.auth_test
  end
end
