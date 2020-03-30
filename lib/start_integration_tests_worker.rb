class StartIntegrationTestsWorker
  include Sidekiq::Worker
  require 'rest-client'
  attr :retry_headers

  def extract_run_url
    10.times do
      result = RestClient.get(GithubValues.workflow_url, @retry_headers || {}) { |response, *_args| response }
      if result.code.eql?(200)
        parsed_result = JSON.parse(result)
        return parsed_result if parsed_result['total_count'].positive?
      end
      @retry_headers = { 'If-None-Match': result.headers[:etag].to_s }
      sleep GithubValues.wait_time
    end
    raise 'Could not get in_progress jobs from github'
  end

  def perform(data)
    dispatch_url = GithubValues.build_url('/dispatches')
    payload = { 'event_type': 'manual-trigger' }
    RestClient.post(dispatch_url, payload.to_json, GithubValues.headers)
    sleep GithubValues.wait_time

    response = extract_run_url['workflow_runs'][0]
    polling_url = response['url']
    web_url = response['html_url']

    SendSlackMessage.new.job_started(data, web_url)
    MonitorTestRunWorker.perform_in(90, polling_url, 45, data, web_url)
  end
end
