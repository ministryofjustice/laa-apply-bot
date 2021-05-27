require 'spec_helper'

RSpec.describe Helm::List do
  describe '#call' do
    subject(:call) { described_class.call }
    before { allow(described_class).to receive(:`).with('helm list -o json').and_return(raw_json) }
    let(:raw_json) do
      [
        {
          'name' => 'apply-ap-1234-first-name',
          'namespace' => 'my-fake-namespace',
          'revision' => '2',
          'updated' => '2021-02-10 14:31:22.723418433 +0000 UTC',
          'status' => 'deployed',
          'chart' => 'my-fake-chart-0.1.0',
          'app_version' => '1.16.0'
        },
        {
          'name' => 'apply-ap-2345-second-name',
          'namespace' => 'my-fake-namespace',
          'revision' => '1',
          'updated' => '2021-02-10 11:52:16.566921696 +0000 UTC',
          'status' => 'deployed',
          'chart' => 'my-fake-chart-0.1.0',
          'app_version' => '1.16.0'
        }
      ].to_json
    end
    let(:expected) do
      '```'\
      "Name                                    Status         Date       Branch PR     \n"\
      "apply-ap-1234-first-name                deployed       2021-02-10\n"\
      'apply-ap-2345-second-name               deployed       2021-02-10'\
      '```'
    end

    it { expect(subject).to eql(expected) }
  end
end
