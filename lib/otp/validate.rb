module OTP
  class Validate
    require 'rotp'

    def initialize(user_id, passcode)
      @user_id = user_id
      @otp = passcode
    end

    def self.call(user_id, passcode)
      new(user_id, passcode).call
    end

    def call
      { valid: totp_result, message: result_message }
    end

    private

    def user
      @user ||= User.find_by(slack_id: @user_id)
    end

    def user_has_github_linked?
      user.github_id.present?
    end

    def totp_result
      return false unless user_has_github_linked?

      @totp_result ||= totp.verify(@otp)
    end

    def totp
      ROTP::TOTP.new(Encryption::Service.decrypt(user.encrypted_2fa_secret), issuer: ENV.fetch('SERVICE_NAME'))
    end

    def result_message
      return nil if totp_result

      if user_has_github_linked?
        'OTP password did not match, please check your authenticator app'
      else
        'You need to link your github account before you can setup 2FA'
      end
    end
  end
end
