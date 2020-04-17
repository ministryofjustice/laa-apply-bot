class MonitorTestRunWorker
  require 'rest-client'
  include Sidekiq::Worker

  def perform(monitor_url, delay, data, web_url)
    data.stringify_keys!
    result = JSON.parse(RestClient.get(monitor_url, GithubValues.headers))
    if result['status'].eql?('completed')
      params = { channel: data['channel'], as_user: true }.merge(SlackAttachment.job_completed(result['conclusion'].eql?('success'), web_url))
      SendSlackMessage.new.job_completed(params)
    else
      # if delay.eql?(11)
      #   message_text = "Tests still running, this can take 2-3 minutes"
      #   new_message = client.chat_postEphemeral(
      #     as_user: true,
      #     user: data['user'],
      #     channel: data['channel'],
      #     text: message_text
      #   )
      # end

      MonitorTestRunWorker.perform_in(delay, monitor_url, delay / 2, data, web_url)
    end
  end
end
