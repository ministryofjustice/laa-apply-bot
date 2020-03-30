module SlackApplybot
  # returns an environment class with uri properties
  class Environment
    APPLICATIONS = %w[apply cfe].freeze
    NON_LIVE_ENVS = %w[staging].freeze
    LIVE_ENV_SYNONYMS = %w[production prod live].freeze
    SERVICE_URL = 'apply-for-legal-aid.service.justice.gov.uk'.freeze
    PREFIX = 'https://'.freeze

    def self.valid?(application, name)
      APPLICATIONS.include?(application) && (NON_LIVE_ENVS.include?(name) || LIVE_ENV_SYNONYMS.include?(name))
    end

    def initialize(application, name)
      @name = name
      @application = application
    end

    def url
      @url ||= if NON_LIVE_ENVS.include?(@name)
                 "#{PREFIX}#{@name}.#{SERVICE_URL}"
               elsif LIVE_ENV_SYNONYMS.include?(@name)
                 "#{PREFIX}#{SERVICE_URL}"
               end
    end

    def ping_page
      "#{url}/ping.json"
    end

    def ping_data
      response = RestClient.get(ping_page)
      JSON.parse(response.body)
    end

    def name
      if LIVE_ENV_SYNONYMS.include?(@name)
        'production'
      elsif NON_LIVE_ENVS.include?(@name)
        @name
      else
        'unknown'
      end
    end
  end
end
