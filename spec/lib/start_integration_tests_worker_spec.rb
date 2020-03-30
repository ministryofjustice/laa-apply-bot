require 'spec_helper'

describe StartIntegrationTestsWorker do
  subject(:worker) { described_class.new }

  before do
    stub_request(:get, %r{\Ahttps://(www|api).github.com/.*/dispatches\z})
      .to_return(status: 204, body: '', headers: {})
    stub_request(:get, %r{\Ahttps://(www|api).github.com/.*/runs.*\z})
      .to_return(status: 200, body: response, headers: {})
  end
  let(:response) { { 'total_count': 1, "workflow_runs": [{ url: '', html_url: '' }] }.to_json }

  it { is_expected.to be_a StartIntegrationTestsWorker }

  describe '.perform' do
    subject(:perform) { worker.perform(data) }

    let(:data) { { channel: 'test', user: 'test' } }

    context 'when the job is successfully started in github and located' do
      it 'polls github for data' do
        perform
        expect(a_request(:post, 'https://api.github.com/repos/moj/project/dispatches')).to have_been_made.times(1)
      end

      it 'sends a message to slack' do
        perform
        expect(a_request(:post, 'https://slack.com/api/chat.postEphemeral')).to have_been_made.times(1)
      end

      it 'creates a new MonitorTestRunWorker' do
        expect { perform }.to change(MonitorTestRunWorker.jobs, :size).by(1)
      end
    end

    context 'when the job is successfully started in github and located' do
      let(:response) { { 'total_count': 0 }.to_json }

      it 'polls github for data' do
        expect { perform }.to raise_error(RuntimeError, 'Could not get in_progress jobs from github')
      end
    end
  end
end
