class SendSlackMessage
  def initialize
    Slack.configure do |config|
      config.token = Settings.slack_api_token
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end
    check_connection
  end

  def job_started(data, web_url)
    data.stringify_keys!
    params = { as_user: true, user: data['user'], channel: data['channel'] }.merge(SlackAttachment.job_started(web_url))
    client.chat_postEphemeral(params)
  end

  def job_completed(params)
    client.chat_postMessage(params)
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def check_connection
    client.auth_test
  end
end
