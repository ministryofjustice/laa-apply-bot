module Github
  class TeamMembership
    ORG_URL = "https://api.github.com/orgs/".freeze
    def initialize(user, group)
      @user = user
      @group = group
    end

    def self.call(user, group)
      new(user, group).call
    end

    def call
      parsed_json_data.map { |x| x["login"] }
    end

    def self.member?(user, group)
      call(user, group).include?(user)
    end

  private

    def parsed_json_data
      raw_data = RestClient.get("#{ORG_URL}#{ENV.fetch('GITHUB_OWNER')}/teams/#{@group}/members", GithubValues.headers)
      JSON.parse(raw_data)
    end
  end
end
