require "rspec"

RSpec.describe Github::PullRequests do
  subject(:pull_requests) { described_class.new(application) }

  let(:application) { ApplyApplication.new }
  let(:truncated_data) do
    [
      { "head" => { "ref" => "ap-1234" } },
      { "head" => { "ref" => "ap-5432" } },
    ]
  end

  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200,
                                                                          body: truncated_data.to_json,
                                                                          headers: {})
  end

  describe ".call" do
    subject(:call) { described_class.call(application) }

    it { is_expected.to eq truncated_data }
  end

  describe "#call" do
    subject(:call) { pull_requests.call }

    it { is_expected.to eq truncated_data }
  end
end
