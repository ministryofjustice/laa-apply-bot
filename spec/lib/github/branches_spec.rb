require 'rspec'

RSpec.describe Github::Branches do
  subject(:pull_requests) { described_class.new(application) }
  let(:application) { ApplyApplication.new }
  before do
    stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200,
                                                                          body: truncated_data.to_json,
                                                                          headers: {})
  end

  let(:truncated_data) do
    [
      { 'name' => 'ap-1234' },
      { 'name' => 'ap-5432' }
    ]
  end

  describe '.call' do
    subject(:call) { described_class.call(application) }

    it { is_expected.to eq truncated_data }
  end

  describe '#call' do
    subject(:call) { pull_requests.call }

    it { is_expected.to eq truncated_data }
  end
end
