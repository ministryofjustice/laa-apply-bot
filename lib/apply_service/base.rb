module ApplyService
  class AbstractClassError < RuntimeError
    def initialize(message = 'ApplyService::Base is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class InvalidApplicationError < RuntimeError
    def initialize(message = 'ApplyService must have a matching _GITHUB_REPO ENV var')
      super(message)
    end
  end

  class Base
    def initialize(name)
      raise AbstractClassError if instance_of?(Base)

      @name = name
      @github_repo = "#{@name.upcase}_GITHUB_REPO"
      raise InvalidApplicationError unless ENV.fetch(@github_repo, nil).present?
    end

    attr_accessor :name

    def github_api_url
      "https://api.github.com/repos/#{ENV.fetch('GITHUB_OWNER')}/#{ENV.fetch(@github_repo)}"
    end
  end
end
