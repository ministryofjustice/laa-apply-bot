class SlackAttachment
  def self.job_completed(passed, web_url)
    new(passed, web_url, 'pass_fail_attachment').call
  end

  def self.job_started(web_url)
    new(true, web_url, 'job_started_attachment').call
  end

  def initialize(passed, web_url, attachment)
    @passed = passed
    @web_url = web_url
    @attachment = send(attachment)
  end

  def call
    response
  end

  private

  def pass_fail_colour
    @passed ? '#36a64f' : '#c41f1f'
  end

  def pass_fail_value
    @passed ? 'Successfully' : 'Failed'
  end

  def pass_fail_fallback
    @passed ? 'Test run has successfully completed' : 'Test run did not succeed'
  end

  def response
    {
      "attachments": [
        {
          "color": pass_fail_colour.to_s
        }.merge(@attachment)
      ]
    }
  end

  def job_started_attachment
    {
      "fallback": "I'll keep you informed automatically (it can take 2-3 minutes)",
      "title": "I'll keep you informed automatically (it can take 2-3 minutes)",
      "text": "or you can <#{@web_url}|click this link> to monitor it on github"
    }
  end

  def pass_fail_attachment
    {
      "fallback": pass_fail_fallback.to_s,
      "title": 'Test run has completed',
      "title_link": @web_url.to_s,
      "fields": [
        {
          "value": pass_fail_value.to_s
        }
      ]
    }
  end
end
