module Worker
  class TestRunStart
    include Sidekiq::Worker
    require 'rest-client'

    class GithubStartJobError < StandardError; end

    def perform(data)
      build_data(data)
      start_test_run

      message = SendSlackMessage.new.generic(
        { channel: @channel, as_user: true }.merge(Slack::BlockBuilder.call(:start))
      )
      TestRunLocate.perform_in(GithubValues.wait_time, @channel, message['ts'], 1, {})
    rescue GithubStartJobError => e
      SendSlackMessage.new.generic(
        { channel: @channel, as_user: true }.merge(Slack::BlockBuilder.start_error(e.message))
      )
    end

    private

    def build_data(data)
      @channel = data['channel']
      @user_id = data['user']
    end

    def start_test_run
      dispatch_url = GithubValues.build_url('/dispatches')
      payload = build_payload.to_json
      RestClient.post(dispatch_url, payload, GithubValues.headers)
    rescue StandardError => e
      raise GithubStartJobError, e
    end

    def user_name
      @user_name ||= SendSlackMessage.find_user(@user_id)&.real_name
    end

    def build_payload
      { 'event_type': 'manual-trigger', 'client_payload': { user: user_name, client: 'apply_bot' } }
    end
  end
end
