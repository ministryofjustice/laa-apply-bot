require 'rspec'
require 'models/user'

describe User, type: :model do
  it { is_expected.to validate_presence_of(:slack_id) }
end
