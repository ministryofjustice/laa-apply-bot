class GithubValues
  def self.headers
    {
      'content_type': ':json',
      'accept': 'application/vnd.github.everest-preview+json',
      'Authorization': "token #{ENV['GITHUB_API_TOKEN']}"
    }
  end

  def self.repo_url
    "https://api.github.com/repos/#{ENV['GITHUB_OWNER']}/#{ENV['GITHUB_REPO']}"
  end

  def self.build_url(suffix)
    "#{repo_url}#{suffix}"
  end

  def self.workflow_url
    build_url('/actions/workflows/manual-integration-tests.yml/runs?status=queued')
  end

  def self.wait_time
    ENV['GITHUB_WAIT_SECONDS'].to_i || 0
  end
end
