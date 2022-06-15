class HmrcInstance < ApplyServiceInstance::Base
  SERVICE_URL = "laa-hmrc-interface.cloud-platform.service.justice.gov.uk".freeze

  def initialize(level)
    super("hmrc", level)
  end

  def url
    if LIVE_ENV_SYNONYMS.include?(@level)
      PREFIX + SERVICE_URL
    elsif NON_LIVE_ENVS.include?(@level)
      "#{PREFIX}#{SERVICE_URL.gsub('-interface', '-interface-staging')}"
    end
  end
end
