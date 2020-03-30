require 'spec_helper'

describe MonitorTestRunWorker do
  subject(:worker) { described_class.new }

  it { is_expected.to be_a MonitorTestRunWorker }

  describe '.perform' do
    subject(:perform) { worker.perform(monitor_url, delay, data, web_url) }
    before do
      stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z})
        .to_return(status: 200, body: response, headers: {})
    end

    let(:monitor_url) { 'https://api.github.com/repos/moj/project/job/123' }
    let(:delay) { 45 }
    let(:data) { { channel: 'test', user: 'test' } }
    let(:web_url) { 'https://www.github.com/repos/moj/project/job/123' }
    let(:response) { { 'status': 'in_progress' }.to_json }

    context 'when the job has not completed' do
      it 'creates a new MonitorTestRunWorker' do
        expect { perform }.to change(MonitorTestRunWorker.jobs, :size).by(1)
      end
    end

    context 'when the job has completed' do
      let(:response) { { 'status': 'completed' }.to_json }

      it 'sends a message to slack' do
        perform
        expect(a_request(:post, 'https://slack.com/api/chat.postMessage')).to have_been_made.times(1)
      end
    end
  end
end
