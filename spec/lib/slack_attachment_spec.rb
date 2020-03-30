require 'spec_helper'

describe SlackAttachment do
  subject(:attachment) { described_class.new(state, url, 'pass_fail_attachment') }
  let(:state) { true }
  let(:url) { 'http://test.com' }

  it { is_expected.to be_a SlackAttachment }

  describe '#job_completed' do
    subject(:attachment) { described_class.job_completed(state, url) }

    it { is_expected.to be_a Hash }
  end

  describe '#job_started' do
    subject(:attachment) { described_class.job_started(url) }

    it { is_expected.to be_a Hash }
  end

  describe '.job_completed' do
    subject(:call) { attachment.call }

    it { is_expected.to be_a Hash }

    context 'when passed false' do
      let(:state) { false }

      it 'returns the fail colour' do
        expect(subject[:attachments][0][:color]).to eql '#c41f1f'
      end
    end
  end
end
