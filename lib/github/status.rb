module Github
  class Status
    def initialize(commit_url)
      @url = "#{commit_url}/status"
    end

    def call
      raw_data = RestClient.get(@url, GithubValues.headers)
      JSON.parse(raw_data)["state"]
    end

    def self.passed?(commit_url)
      new(commit_url).call.eql?("success")
    end
  end
end
