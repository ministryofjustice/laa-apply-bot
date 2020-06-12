require 'spec_helper'
require 'date_display'

describe CfeApplication do
  subject(:base) { described_class.new }

  it { is_expected.to be_a CfeApplication }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :github_api_url }

  describe '.name' do
    subject(:name) { base.name }

    it { is_expected.to eq 'CFE' }
  end

  describe '.github_api_url' do
    subject(:github_api_url) { base.github_api_url }

    it { is_expected.to eq 'https://api.github.com/repos/moj/project-api' }
  end
end
