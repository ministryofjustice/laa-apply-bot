module ApplyInstance
  class AbstractClassError < RuntimeError
    def initialize(message = 'ApplyService::Base is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class InvalidApplicationError < RuntimeError
    def initialize(message = 'ApplyInstance must match known APPLICATIONS')
      super(message)
    end
  end

  class InvalidInstantiationError < RuntimeError
    def initialize(message = 'ApplicationInstance requires type and level variables')
      super(message)
    end
  end

  class Base
    APPLICATIONS = %w[apply cfe].freeze
    NON_LIVE_ENVS = %w[staging].freeze
    LIVE_ENV_SYNONYMS = %w[production prod live].freeze
    SERVICE_URL = 'apply-for-legal-aid.service.justice.gov.uk'.freeze
    PREFIX = 'https://'.freeze

    attr_accessor :type, :level

    def initialize(type, level)
      raise 'ApplyInstance base class cannot be initialized' if self.class == Base
      raise InvalidInstantiationError if type.nil? || level.nil?
      raise ApplyInstance::InvalidApplicationError unless APPLICATIONS.include?(type)

      @type = type
      @level = level
    end

    def url
      # cfe-live 'http://check-financial-eligibility.apps.live-1.cloud-platform.service.justice.gov.uk/'
      # cfe-staging 'check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk'
      if LIVE_ENV_SYNONYMS.include?(@level)
        PREFIX + SERVICE_URL
      elsif NON_LIVE_ENVS.include?(@level)
        "#{PREFIX}#{@level}.#{SERVICE_URL}"
      end
    end

    def ping_url
      "#{url}/ping.json"
    end

    def ping_data
      response = RestClient.get(ping_url)
      JSON.parse(response.body)
    end
  end
end
