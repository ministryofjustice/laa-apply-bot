require "spec_helper"

describe GithubValues do
  subject(:base) { described_class.new }

  before { allow(ENV).to receive(:[]).and_call_original }

  let(:base_url) { "https://api.github.com/repos/moj/project" }

  it { is_expected.to be_a described_class }

  describe "#headers" do
    subject(:headers) { described_class.headers }

    let(:json_keys) { %i[content_type accept Authorization] }

    it { is_expected.to be_a Hash }
    it { expect(headers.keys).to contain_exactly(*json_keys) }
  end

  describe "#repo_url" do
    subject(:repo_url) { described_class.repo_url }

    it { is_expected.to eql(base_url) }
  end

  describe "#build_url" do
    subject(:build_url) { described_class.build_url(extension) }

    let(:extension) { "/extend" }

    it { is_expected.to eql("https://api.github.com/repos/moj/project/extend") }
  end

  describe "#running_job_url" do
    subject(:running_job_url) { described_class.running_job_url }

    it { is_expected.to eql("#{base_url}/actions/workflows/manual-integration-tests.yml/runs?status=in_progress") }
  end

  describe "#wait_time" do
    subject(:wait_time) { described_class.wait_time }

    context "when a value is set" do
      before { allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(1) }

      it { is_expected.to eq 1 }
    end

    context "when an setting is not present" do
      before { allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(0) }

      it { is_expected.to eq 0 }
    end
  end
end
