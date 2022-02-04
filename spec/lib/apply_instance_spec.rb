require "spec_helper"

describe ApplyInstance do
  subject(:application_instance) { described_class.new(level) }

  let(:level) { "live" }

  it { is_expected.to be_a described_class }

  describe "url" do
    subject(:url) { application_instance.url }

    context "when level is production-like" do
      it { is_expected.to eql "https://apply-for-legal-aid.service.justice.gov.uk" }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql "https://staging.apply-for-legal-aid.service.justice.gov.uk" }
    end
  end

  describe "ping_url" do
    subject(:ping_url) { application_instance.ping_url }

    context "when level is production-like" do
      it { is_expected.to eql "https://apply-for-legal-aid.service.justice.gov.uk/ping.json" }
    end

    context "when level staging" do
      let(:level) { "staging" }

      it { is_expected.to eql "https://staging.apply-for-legal-aid.service.justice.gov.uk/ping.json" }
    end
  end

  describe "ping_data", :vcr do
    subject(:ping_data) { application_instance.ping_data }

    context "when level staging" do
      let(:level) { "staging" }
      let(:expected_json) do
        {
          "build_date" => "2020-03-20T13:59:40+0000",
          "build_tag" => "app-ccf322d51b508fd16316d24593a44e9c887be281",
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
