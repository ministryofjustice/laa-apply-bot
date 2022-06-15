class LfaInstance < ApplyServiceInstance::Base
  SERVICE_URL = "legal-framework-api.cloud-platform.service.justice.gov.uk".freeze

  def initialize(level)
    super("lfa", level)
  end

  def url
    if LIVE_ENV_SYNONYMS.include?(@level)
      PREFIX + SERVICE_URL
    elsif NON_LIVE_ENVS.include?(@level)
      "#{PREFIX}#{SERVICE_URL.gsub('-api', '-api-staging')}"
    end
  end
end
