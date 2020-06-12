class CfeInstance < ApplyServiceInstance::Base
  SERVICE_URL = 'check-financial-eligibility.apps.live-1.cloud-platform.service.justice.gov.uk'.freeze

  def initialize(level)
    super('cfe', level)
  end

  def url
    if LIVE_ENV_SYNONYMS.include?(@level)
      PREFIX + SERVICE_URL
    elsif NON_LIVE_ENVS.include?(@level)
      "#{PREFIX}#{SERVICE_URL.gsub('.apps', '-staging.apps')}"
    end
  end
end
