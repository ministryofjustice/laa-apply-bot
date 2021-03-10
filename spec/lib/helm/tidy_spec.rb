require 'spec_helper'

RSpec.describe Helm::Tidy do
  describe '#call' do
    subject(:call) { described_class.call }
    before do
      allow(described_class).to receive(:`).with('helm list -o json').and_return(raw_json)
      stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z}).to_return(status: 200,
                                                                            body: truncated_branch_data.to_json,
                                                                            headers: {})
    end
    let(:truncated_branch_data) do
      [
        { 'name' => 'ap-1234-first-name' },
        { 'name' => 'ap-5432-second-name' }
      ]
    end

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
      ":yep: apply-ap-1234-first-name - retaining because branch still exists\n" \
      ':nope: apply-ap-2345-second-name - branch deleted - you can run the following locally  - ' \
        "helm delete apply-ap-2345-second-name --dry-run\n"
    end

    it { expect(subject).to eql(expected) }
  end
end
