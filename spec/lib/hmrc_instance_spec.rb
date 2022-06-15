require "spec_helper"

describe HmrcInstance do
  subject(:application_instance) { described_class.new(level) }

  let(:live_url) { "https://laa-hmrc-interface.cloud-platform.service.justice.gov.uk" }
  let(:staging_url) { "https://laa-hmrc-interface-staging.cloud-platform.service.justice.gov.uk" }
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
          "build_date" => "2022-06-15T06:21:41.000+00:00",
          "build_tag" => "app-9ea4a2ab7edb6ee71d12d16726fc2db7b31875e4",
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
