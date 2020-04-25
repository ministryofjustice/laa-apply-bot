require 'rspec'
require 'lib/kubectl'

RSpec.describe Kubectl do
  subject(:kubectl) { described_class.new }

  before do
    allow_any_instance_of(Kubectl).to receive(:ingresses).with('laa-apply-for-legalaid-uat').and_return(valid_json)
  end

  let(:valid_json) { [response: 'true'] }

  describe '.uat_ingresses' do
    subject(:uat_ingresses) { kubectl.uat_ingresses }

    it { is_expected.to be_a Array }
  end

  describe '#uat_ingresses' do
    subject(:uat_ingresses) { described_class.uat_ingresses }

    it { is_expected.to be_a Array }
  end
end
