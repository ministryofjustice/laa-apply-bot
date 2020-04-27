class User < ActiveRecord::Base
  validates :slack_id, presence: true
end
