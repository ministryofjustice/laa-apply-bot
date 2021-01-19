require 'rspec'
require 'support/commit'

RSpec.describe Github::Commits do
  subject(:github_commits) { described_class.new(application) }
  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200, body: commits, headers: {})
  end
  let(:application) { ApplyApplication.new }
  load_shared_commit_data
  let(:expected_response) do
    <<~RESPONSE.chomp
      Merge pull request #1999 from moj/AA-1234
      Merge pull request #1998 from moj/AA-421
      Merge pull request #1997 from moj/AA-666
      Merge pull request #1996 from moj/AA-555
      Merge pull request #1995 from moj/AA-444
    RESPONSE
  end

  describe '.call' do
    subject(:call) { described_class.call(application) }

    it { is_expected.to eq expected_response }
  end

  describe '#call' do
    subject(:call) { github_commits.call }

    it { is_expected.to eq expected_response }
  end
end
