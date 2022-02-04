require "rspec"
require "support/commit"

RSpec.describe Github::TeamMembership do
  subject(:github_team_membership) { described_class.new(user, group) }
  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*/members\z})
      .to_return(status: 200, body: expected, headers: {})
  end

  let(:user) { "good_user" }
  let(:group) { "test_group" }
  let(:expected) do
    [
      {
        "login" => "good_user",
        "id" => "123456",
        "type" => "user",
      },
      {
        "login" => "colleague",
        "id" => "654321",
        "type" => "user",
      },

    ].to_json
  end

  describe "#call" do
    subject(:call) { github_team_membership.call }

    it { is_expected.to eq %w[good_user colleague] }
  end

  describe ".member?" do
    subject(:member?) { described_class.member?(user, group) }

    context "when the user is in the group" do
      it { is_expected.to be true }
    end

    context "when the user is not in the group" do
      let(:user) { "bad_user" }

      it { is_expected.to be false }
    end
  end
end
