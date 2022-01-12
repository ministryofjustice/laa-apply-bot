require 'spec_helper'

RSpec.describe Helm::Tidy do
  describe '#call' do
    subject(:call) { described_class.call(match_data, channel) }
    let(:channel) { 'shared_channel' }
    let(:match_data) { { bot: 'bot_name', 'command' => 'helm', 'expression' => command } }
    let(:command) { 'clean' }

    let(:github_url) { 'https://api.github.com/repos/moj/project-app' }

    context 'when instances are identified for removal' do
      before do
        allow_any_instance_of(described_class).to receive(:`)
          .with('helm list --kube-context apply-context -o json')
          .and_return(raw_json)
        stub_request(:get, "#{github_url}/branches?per_page=100").to_return(status: 200,
                                                                            body: truncated_branch_data.to_json,
                                                                            headers: {})
        stub_request(:get, "#{github_url}/pulls").to_return(status: 200,
                                                            body: truncated_pr_data.to_json,
                                                            headers: {})
      end
      let(:truncated_branch_data) do
        [
          { 'name' => 'ap-1234-first-name' },
          { 'name' => 'ap-5432-second-name' }
        ]
      end
      let(:truncated_pr_data) do
        [
          { 'head' => { 'ref' => 'ap-1234-first-name' } },
          { 'head' => { 'ref' => 'ap-5432-second-name' } }
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

      it 'sends a generic slack message' do
        expect_any_instance_of(SendSlackMessage).to receive(:generic).once
        expect(subject).to be_nil
      end
    end
    context 'when no instances are identified for removal' do
      before do
        allow_any_instance_of(described_class).to receive(:`)
          .with('helm list --kube-context apply-context -o json')
          .and_return(raw_json)
        stub_request(:get, "#{github_url}/branches?per_page=100").to_return(status: 200,
                                                                            body: truncated_branch_data.to_json,
                                                                            headers: {})
        stub_request(:get, "#{github_url}/pulls").to_return(status: 200,
                                                            body: truncated_pr_data.to_json,
                                                            headers: {})
      end
      let(:truncated_branch_data) do
        [
          { 'name' => 'ap-1234-first-name' },
          { 'name' => 'ap-5432-second-name' }
        ]
      end
      let(:truncated_pr_data) do
        [
          { 'head' => { 'ref' => 'ap-1234-first-name' } },
          { 'head' => { 'ref' => 'ap-5432-second-name' } }
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
            'name' => 'apply-ap-5432-second-name',
            'namespace' => 'my-fake-namespace',
            'revision' => '1',
            'updated' => '2021-02-10 11:52:16.566921696 +0000 UTC',
            'status' => 'deployed',
            'chart' => 'my-fake-chart-0.1.0',
            'app_version' => '1.16.0'
          }
        ].to_json
      end

      it 'sends a generic slack message' do
        expect_any_instance_of(SendSlackMessage).to_not receive(:generic)
        expect(subject).to eq 'There do not seem to be any instances deletable for Apply'
      end
    end
  end
end
