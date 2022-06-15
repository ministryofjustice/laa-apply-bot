require "spec_helper"

describe LfaInstance do
  subject(:application_instance) { described_class.new(level) }

  let(:live_url) { "https://legal-framework-api.cloud-platform.service.justice.gov.uk" }
  let(:staging_url) { "https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk" }
  let(:level) { "live" }

  it { is_expected.to be_a described_class }

  describe "url" do
    subject(:url) { application_instance.url }

    context "when level is production-like" do
      it { is_expected.to eql live_url }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql staging_url }
    end
  end

  describe "ping_url" do
    subject(:ping_url) { application_instance.ping_url }

    context "when level is production-like" do
      it { is_expected.to eql "#{live_url}/ping.json" }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql "#{staging_url}/ping.json" }
    end
  end

  describe "ping_data", :vcr do
    subject(:ping_data) { application_instance.ping_data }

    context "when level staging" do
      let(:level) { "staging" }
      let(:expected_json) do
        {
          "build_date" => "2022-06-14T06:24:58+0000",
          "build_tag" => "app-42c22014522e6ae61dc9a16cfea7211266872b8d",
          "app_branch" => "main",
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
