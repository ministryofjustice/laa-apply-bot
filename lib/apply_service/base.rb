module ApplyService
  class Base
    def initialize
      raise 'ApplyService base class cannot be initialized' if self.class == Base
    end

    def name
      @application
    end

    def github_api_url
      "https://api.github.com/repos/#{ENV['GITHUB_OWNER']}/#{ENV.fetch("#{@application.upcase}_GITHUB_REPO")}"
    end
  end
end
