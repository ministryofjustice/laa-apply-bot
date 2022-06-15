module GithubBits
  PREFIX = "apply-".freeze

private

  def branch_data
    @branch_data ||= JSON.parse(@application.open_branches.to_json, symbolize_names: true).map do |branch|
      branch[:name]
    end
  end

  def branch_still_exists(environment)
    branch_data.map { |pr_title| pr_title.include?(environment.delete_prefix(PREFIX)) }.any?
  end

  def pull_request_data
    @pull_request_data ||= JSON.parse(@application.open_pull_requests.to_json, symbolize_names: true).map do |pr|
      pr[:head][:ref].gsub(%r{[()\[\]_/\s.]}, "-")
    end
  end

  def pr_still_exists(environment)
    pull_request_data.map { |pr_title| pr_title.include?(environment.delete_prefix(PREFIX)) }.any?
  end

  def still_exists?(environment)
    branch_still_exists(environment) || pr_still_exists(environment)
  end
end
