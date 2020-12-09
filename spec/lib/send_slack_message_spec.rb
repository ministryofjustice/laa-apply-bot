require 'spec_helper'

RSpec.describe SendSlackMessage do
  subject(:slack) { described_class.new }

  it { is_expected.to be_a SendSlackMessage }

  context 'when a slack token is not set' do
    before { allow(ENV).to receive(:[]).with('SLACK_API_TOKEN').and_return(nil) }

    it 'raises an error' do
      expect { slack }.to raise_error('Missing ENV[SLACK_API_TOKEN]!')
    end
  end

  describe '.generic' do
    subject(:generic) { slack.generic(params) }

    let(:params) { { channel: 'test', user: 'test', attachments: [] } }

    it 'sends a message to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/chat.postMessage')).to have_been_made.times(1)
    end
  end

  describe '.upload_file' do
    subject(:upload_file) { slack.upload_file(params) }

    let(:params) { { channels: 'test', content: 'test', filename: 'output.txt' } }

    it 'sends a message to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/files.upload')).to have_been_made.times(1)
    end
  end

  describe '.conversations_info' do
    subject(:conversations_info) { slack.conversations_info(params) }

    let(:params) { { channel: 'test' } }

    it 'sends a message to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/conversations.info')).to have_been_made.times(1)
    end
  end

  describe '.update' do
    subject(:update) { slack.update(params) }

    let(:params) { { ts: '0000.000', channel: 'test', user: 'test', attachments: [] } }

    it 'sends an update post to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/chat.update')).to have_been_made.times(1)
    end
  end

  describe '.user' do
    subject(:update) { slack.user(params) }
    let(:params) { { user_id: 'test' } }

    it 'sends an user POST request to slack' do
      subject
      expect(a_request(:post, 'https://slack.com/api/users.info')).to have_been_made.times(1)
    end
  end
end
