require 'spec_helper'

describe ApplicationInstance do
  subject(:application_instance) { described_class.new(type, level) }
  let(:type) { 'apply' }
  let(:level) { 'live' }

  it { is_expected.to be_a ApplicationInstance }

  describe 'url' do
    subject(:url) { application_instance.url }

    context 'when level is production-like' do
      it { is_expected.to eql 'https://apply-for-legal-aid.service.justice.gov.uk' }
    end

    context 'when level staging' do
      let(:level) { 'staging' }

      it { is_expected.to eql 'https://staging.apply-for-legal-aid.service.justice.gov.uk' }
    end
  end

  describe 'ping_url' do
    subject(:ping_url) { application_instance.ping_url }

    context 'when level is production-like' do
      it { is_expected.to eql 'https://apply-for-legal-aid.service.justice.gov.uk/ping.json' }
    end

    context 'when level staging' do
      let(:level) { 'staging' }

      it { is_expected.to eql 'https://staging.apply-for-legal-aid.service.justice.gov.uk/ping.json' }
    end
  end

  describe 'ping_data', :vcr do
    subject(:ping_data) { application_instance.ping_data }

    context 'when level staging' do
      let(:level) { 'staging' }
      let(:expected_json) do
        {
          'build_date' => '2020-03-20T13:59:40+0000',
          'build_tag' => 'app-ccf322d51b508fd16316d24593a44e9c887be281',
          'app_branch' => 'master'
        }
      end

      it { is_expected.to eql expected_json }
    end
  end

  describe 'instantiation fails' do
    { type: { type: nil, level: 'live' },
      level: { type: 'apply', level: nil },
      both: { type: nil, level: nil } }.each do |k, v|
      context "when #{k} is missing" do
        let(:type) { v[:type] }
        let(:level) { v[:level] }

        it { expect { application_instance }.to raise_error(ApplyInstance::InvalidInstantiationError) }
      end
    end

    context 'when passed an invalid application name' do
      let(:type) { 'cccd' }

      it { expect { application_instance }.to raise_error(ApplyInstance::InvalidApplicationError) }
    end
  end
end
