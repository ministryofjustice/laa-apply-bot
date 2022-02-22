class TokenGenerator
  require "ostruct"
  require "base64"
  require "json"

  def self.call(slack_id)
    new.call(slack_id)
  end

  def call(slack_id)
    token = { slack_id:, expires_at: Time.now + (10 * 60), secret: ENV.fetch("SECRET_KEY_BASE") }
    Base64.urlsafe_encode64(token.to_json)
  end
end
