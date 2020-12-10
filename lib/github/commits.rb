module Github
  class Commits
    def initialize(application)
      @application = application
    end

    def self.call(application)
      new(application).call
    end

    def call
      # TODO: Next steps
      # - limit numbers? Should we allow the user to request
      #   an amount e.g. ages 6 for 6 commits per application?
      # - implement Github status class so we could pass a sha and get a status on each merge job
      raw_data = RestClient.get("#{@application.github_api_url}/commits", GithubValues.headers)
      json = JSON.parse(raw_data)

      output = []
      json.each do |pr|
        message = pr['commit']['message'].split("\n").first
        output << message if message.start_with?('Merge')
        break if output.count.eql?(5)
      end
      output.join("\n")
    end
  end
end
