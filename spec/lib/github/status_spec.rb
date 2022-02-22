require "rspec"
require "support/commit"

RSpec.describe Github::Status do
  subject(:github_status) { described_class.new(url) }
  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*/status\z})
      .to_return(status: 200, body: expected, headers: {})
  end
  let(:url) { "https://api.github.com/repos/moj/project/commits/123456" }
  let(:expected) do
    {
      "state" => "pending"
    }.to_json
  end
  load_shared_commit_data

  describe "#call" do
    subject(:call) { github_status.call }

    it { is_expected.to eq "pending" }
  end

  describe ".passed?" do
    subject(:passed?) { described_class.passed?(url) }

    it { is_expected.to be false }
  end
end
