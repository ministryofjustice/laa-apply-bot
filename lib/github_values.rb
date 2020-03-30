class GithubValues
  def self.headers
    {
      'content_type': ':json',
      'accept': 'application/vnd.github.everest-preview+json',
      'Authorization': "token #{Settings.github_api_tokens}"
    }
  end

  def self.repo_url
    "https://api.github.com/repos/#{Settings.github_owner}/#{Settings.github_repo}"
  end

  def self.build_url(suffix)
    "#{repo_url}#{suffix}"
  end

  def self.workflow_url
    build_url('/actions/workflows/manual-integration-tests.yml/runs?status=queued')
  end

  def self.wait_time
    Settings.github_wait_seconds.to_i || 0
  end
end
