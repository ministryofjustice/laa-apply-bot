module Worker
  class TestRunMonitor
    require "rest-client"
    include Sidekiq::Worker

    def perform(monitor_url, delay, channel, web_url, message_ts)
      result = call_github(monitor_url)
      if result["status"].eql?("completed")
        block = Slack::BlockBuilder.call(:complete, result: result["conclusion"].eql?("success"), web_url: web_url)
        SendSlackMessage.new.update({ ts: message_ts, channel: channel, as_user: true }.merge(block))
      else
        TestRunMonitor.perform_in(delay, monitor_url, delay / 2, channel, web_url, message_ts)
      end
    end

    private

    def call_github(monitor_url)
      JSON.parse(RestClient.get(monitor_url, GithubValues.headers))
    end
  end
end
