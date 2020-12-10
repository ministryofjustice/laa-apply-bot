require 'rspec'

RSpec.describe Github::Commits do
  subject(:github_commits) { described_class.new(application) }
  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200, body: commits, headers: {})
  end
  let(:application) { ApplyApplication.new }
  let(:commits) do
    [
      {
        "sha": '123456',
        "commit": { "message": "Merge pull request #1999 from moj/AA-1234\n\nImprove something important" }
      },
      {
        "sha": '234567',
        "commit": { "message": "Merge pull request #1998 from moj/AA-421\n\nMinor tweak to something" }
      },
      {
        "sha": '345678',
        "commit": { "message": "Improve the thing\n\nSo that the other thing looks better" }
      },
      {
        "sha": '456789',
        "commit": { "message": "Tweak the layout of results\n\nShould have been left aligned" }
      },
      {
        "sha": '678912',
        "commit": { "message": "Merge pull request #1997 from moj/AA-666\n\nMade everything shiny" }
      },
      {
        "sha": '789123',
        "commit": { "message": "Merge pull request #1996 from moj/AA-555\n\nMade everything dull" }
      },
      {
        "sha": '891234',
        "commit": { "message": "Merge pull request #1995 from moj/AA-444\n\nMade everything work" }
      },
      {
        "sha": '567891',
        "commit": { "message": "Merge pull request #1994 from moj/AA-333\n\nMade some stuff work" }
      }
    ].to_json
  end
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
