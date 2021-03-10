class User < ActiveRecord::Base
  validates :slack_id, presence: true, uniqueness: true

  def otp_secret_valid?(value)
    Encryption::Service.decrypt(encrypted_2fa_secret).eql?(value)
  end

  def otp_secret=(value)
    update(encrypted_2fa_secret: Encryption::Service.encrypt(value), enabled_2fa: true)
    save!
  end
end
