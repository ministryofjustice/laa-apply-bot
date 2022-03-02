FactoryBot.define do
  factory :user do
    slack_id { "UQ123ABCD" }
    github_id {}
    enabled_2fa {}
    encrypted_2fa_secret {}
    last_2fa_at {}

    trait :with_2fa do
      enabled_2fa { true }
      encrypted_2fa_secret { Encryption::Service.encrypt("secret") }
    end
  end
end
