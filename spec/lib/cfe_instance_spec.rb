require "spec_helper"

LIVE_URL = "https://check-financial-eligibility.apps.live-1.cloud-platform.service.justice.gov.uk".freeze
STAGING_URL = "https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk".freeze

describe CfeInstance do
  subject(:application_instance) { described_class.new(level) }
  let(:level) { "live" }

  it { is_expected.to be_a described_class }

  describe "url" do
    subject(:url) { application_instance.url }

    context "when level is production-like" do
      it { is_expected.to eql "https://check-financial-eligibility.apps.live-1.cloud-platform.service.justice.gov.uk" }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql STAGING_URL }
    end
  end

  describe "ping_url" do
    subject(:ping_url) { application_instance.ping_url }

    context "when level is production-like" do
      it { is_expected.to eql "#{LIVE_URL}/ping.json" }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql "#{STAGING_URL}/ping.json" }
    end
  end

  describe "ping_data", :vcr do
    subject(:ping_data) { application_instance.ping_data }

    context "when level staging" do
      let(:level) { "staging" }
      let(:expected_json) do
        {
          "build_date" => "2020-05-26T09:46:42+0100",
          "build_tag" => "app-a1bd774c68094caa2a7f4b3d505e826a0aa68dc7",
          "app_branch" => "master",
        }
      end

      it { is_expected.to eql expected_json }
    end
  end

  describe "name" do
    subject(:name) { application_instance.name }

    it { is_expected.to eql("production") }
  end

  describe "when level is not provided, instantiation fails" do
    let(:level) { nil }

    it { expect { application_instance }.to raise_error(ApplyServiceInstance::InvalidInstantiationError) }
  end
end
