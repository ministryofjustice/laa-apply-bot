require 'spec_helper'

describe SlackApplybot::Environment do
  subject(:environment) { described_class.new(application, env_name) }

  context 'when passed an invalid application name' do
    let(:application) { 'bob' }

    subject(:valid?) { described_class.valid?(application, env_name) }

    %w[invalid staging].each do |name|
      let(:env_name) { name }
      context "when passed #{name}" do
        it { is_expected.to be false }
      end
    end
  end

  context 'when passed a valid application name' do
    let(:application) { 'cfe' }

    context 'when passed a non-live env name' do
      let(:env_name) { 'staging' }

      describe '.url' do
        subject(:url) { environment.url }

        it { is_expected.to eql('https://staging.apply-for-legal-aid.service.justice.gov.uk') }
      end

      describe '.ping_page' do
        subject(:ping_page) { environment.ping_page }

        it { is_expected.to eql('https://staging.apply-for-legal-aid.service.justice.gov.uk/ping.json') }
      end

      describe '.name' do
        subject(:name) { environment.name }

        it { is_expected.to eql('staging') }
      end
    end

    context 'when passed a live synonym' do
      let(:env_name) { 'prod' }

      describe '.url' do
        subject(:url) { environment.url }

        it { is_expected.to eql('https://apply-for-legal-aid.service.justice.gov.uk') }
      end

      describe '.ping_page' do
        subject(:ping_page) { environment.ping_page }

        it { is_expected.to eql('https://apply-for-legal-aid.service.justice.gov.uk/ping.json') }
      end
    end

    context 'live synonyms all return the same end point and name' do
      let(:expected_url) { 'https://apply-for-legal-aid.service.justice.gov.uk' }

      %w[production prod live].each do |env_name|
        it { expect(described_class.new(application, env_name).url).to eql(expected_url) }
        it { expect(described_class.new(application, env_name).name).to eql('production') }
      end
    end
  end
end
