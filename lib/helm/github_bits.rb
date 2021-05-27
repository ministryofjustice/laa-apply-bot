module GithubBits
  PREFIX = 'apply-'.freeze

  private

  def open_branches
    application = ApplyApplication.new
    Github::Branches.call(application)
  end

  def branch_data
    @branch_data ||= JSON.parse(open_branches.to_json, symbolize_names: true).map do |branch|
      branch[:name]
    end
  end

  def branch_still_exists(environment)
    branch_data.map { |pr_title| pr_title.include?(environment.delete_prefix(PREFIX)) }.any?
  end

  def open_pull_requests
    application = ApplyApplication.new
    Github::PullRequests.call(application)
  end

  def pull_request_data
    @pull_request_data ||= JSON.parse(open_pull_requests.to_json, symbolize_names: true).map do |pr|
      pr[:head][:ref].gsub(%r{[()\[\]_/\s.]}, '-')
    end
  end

  def pr_still_exists(environment)
    pull_request_data.map { |pr_title| pr_title.include?(environment.delete_prefix(PREFIX)) }.any?
  end

  def still_exists?(environment)
    branch_still_exists(environment) || pr_still_exists(environment)
  end
end
