module Github
  class PullRequests
    def initialize(application)
      @application = application
    end

    def self.call(application)
      new(application).call
    end

    def call
      parsed_json_data
    end

    private

    def parsed_json_data
      raw_data = RestClient.get("#{@application.github_api_url}/pulls", GithubValues.headers)
      JSON.parse(raw_data)
    end
  end
end
