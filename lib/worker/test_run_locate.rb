require "dotiw"
module Worker
  class TestRunLocate
    include Sidekiq::Worker
    include DOTIW::Methods

    class GithubTimeoutError < StandardError; end

    def perform(channel, message_ts, iteration, etag)
      @etag = etag
      @iteration = iteration
      raise GithubTimeoutError if duration >= 120

      running_job = find_in_progress_job
      update_process(channel, iteration, message_ts, running_job)
    rescue GithubTimeoutError
      send_message(Slack::BlockBuilder.timeout_error, channel, message_ts)
    end

    private

    def update_process(channel, iteration, message_ts, running_job)
      if running_job.is_a?(Hash)
        update_and_monitor(channel, message_ts, running_job)
      else
        wait_and_try_again(channel, iteration, message_ts)
      end
    end

    def update_and_monitor(channel, message_ts, running_job)
      polling_url = running_job["workflow_runs"][0]["url"]
      web_url = get_web_url_from(running_job)
      TestRunMonitor.perform_in(45, polling_url, 30, channel, web_url, message_ts)
      send_message(Slack::BlockBuilder.call(:waiting, web_url:), channel, message_ts)
    end

    def wait_and_try_again(channel, iteration, message_ts)
      block = Slack::BlockBuilder.call(:searching, duration: distance_of_time_in_words(duration))
      send_message(block, channel, message_ts)
      TestRunLocate.perform_in(GithubValues.wait_time, channel, message_ts, iteration + 1, @etag)
    end

    def duration
      @duration ||= GithubValues.wait_time * @iteration
    end

    def find_in_progress_job
      result = rest_client_get_response(GithubValues.running_job_url, GithubValues.headers.merge(retry_headers || {}))
      if result.code.eql?(200)
        json_result = JSON.parse(result)
        parsed_result = json_result["total_count"].positive? ? json_result : negative_result(json_result)
      else
        parsed_result = "negative - status"
      end
      @etag = { 'If-None-Match' => result.headers[:etag].to_s }
      parsed_result
    end

    def negative_result(json_result)
      "negative - total_count ```#{json_result}```"
    end

    def get_web_url_from(running_job)
      job_data = rest_client_get_response(running_job["workflow_runs"][0]["jobs_url"])
      "#{JSON.parse(job_data)['jobs'][0]['html_url']}?check_suite_focus=true"
    end

    def rest_client_get_response(url, headers = {})
      RestClient.get(url, headers) { |response, *_args| response }
    end

    def retry_headers
      @etag.present? ? { 'If-None-Match': @etag.to_s } : {}
    end

    def send_message(block, channel, timestamp)
      SendSlackMessage.new.update(build_params(block, channel, timestamp))
    end

    def build_params(block, channel, timestamp)
      { ts: timestamp, channel:, as_user: true }.merge(block)
    end
  end
end
