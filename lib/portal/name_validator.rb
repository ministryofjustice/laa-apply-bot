module Portal
  class NameValidator
    def initialize(name)
      raise 'Name is invalid type' unless name.is_a?(Portal::Name)

      @name = name
    end

    def call
      validate
    end

    def self.call(name)
      new(name).call
    end

    private

    def validate
      return error_state unless parse_uri
      return error_state(format_error_message) if raw_response.code != '200'

      @name.portal_name_valid = true
      true
    end

    def error_state(message = nil)
      @name.portal_name_valid = false
      @name.errors = message if message.present?
      false
    end

    def parse_uri
      @parsed_uri = URI.parse(provider_details_url)
    rescue URI::InvalidURIError
      @name.errors = "'#{@name.display_name}' contains unicode characters, please re-type if cut and pasted"
      false
    end

    def raw_response
      @raw_response ||= Net::HTTP.get_response(@parsed_uri)
    end

    def provider_details_url
      File.join(ENV['PROVIDER_DETAILS_URL'], @name.portal_username)
    end

    def format_error_message
      if raw_response.code == '404'
        "User #{@name.portal_username} not known to CCMS"
      else
        "Bad response from Provider Details API: HTTP status #{raw_response.code}"
      end
    end
  end
end
