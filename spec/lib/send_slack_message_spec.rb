require 'spec_helper'

RSpec.describe SendSlackMessage do
  subject(:slack) { described_class.new }

  it { is_expected.to be_a SendSlackMessage }

  context 'when a slack token is not set' do
    before { allow(Settings).to receive(:slack_api_token).and_return nil }

    it 'raises an error' do
      expect { slack }.to raise_error('Missing ENV[SLACK_API_TOKEN]!')
    end
  end

  context '.job_started' do
    subject(:job_started) { slack.job_started(data, web_url) }

    let(:data) { { channel: 'test', user: 'test' } }
    let(:web_url) { 'http://test.com' }

    it 'sends a message to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/chat.postEphemeral')).to have_been_made.times(1)
    end
  end

  context '.job_completed' do
    subject(:job_completed) { slack.job_completed(params) }

    let(:params) { { channel: 'test', user: 'test', attachments: [] } }

    it 'sends a message to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/chat.postMessage')).to have_been_made.times(1)
    end
  end
end
