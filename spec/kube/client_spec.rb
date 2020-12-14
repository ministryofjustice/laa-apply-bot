require 'rspec'

describe Kube::Client do
  subject(:kube_client) { described_class.call }

  it { is_expected.to be_a Kubeclient::Client }
end
