class MonitorTestRunWorker
  require 'rest-client'
  include Sidekiq::Worker

  def perform(monitor_url, delay, data, web_url)
    data.stringify_keys!
    result = call_github(monitor_url)
    if result['status'].eql?('completed')
      slack_attachment = SlackAttachment.job_completed(result['conclusion'].eql?('success'), web_url)
      params = { channel: data['channel'], as_user: true }.merge(slack_attachment)
      SendSlackMessage.new.job_completed(params)
    else
      MonitorTestRunWorker.perform_in(delay, monitor_url, delay / 2, data, web_url)
    end
  end

  private

  def call_github(monitor_url)
    JSON.parse(RestClient.get(monitor_url, GithubValues.headers))
  end
end
