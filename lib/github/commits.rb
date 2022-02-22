module Github
  class Commits
    def initialize(application)
      @application = application
      @deploy_has_succeeded = false
    end

    def self.call(application)
      new(application).call
    end

    def call
      # TODO: Next steps
      # - limit numbers? Should we allow the user to request
      #   an amount e.g. ages 6 for 6 commits per application?
      output = []
      parsed_json_data.each do |pr|
        message = pr["commit"]["message"].split("\n").first
        output << "#{state_icon_for(pr)} #{message}" if message.start_with?("Merge")
        break if output.count.eql?(5)
      end
      output.join("\n")
    end

  private

    def parsed_json_data
      raw_data = RestClient.get("#{@application.github_api_url}/commits", GithubValues.headers)
      JSON.parse(raw_data)
    end

    def state_icon_for(pull_request)
      if @deploy_has_succeeded
        ":yep:"
      else
        @deploy_has_succeeded = Github::Status.passed?(pull_request["url"])
        @deploy_has_succeeded ? ":yep:" : ":nope:"
      end
    end
  end
end
