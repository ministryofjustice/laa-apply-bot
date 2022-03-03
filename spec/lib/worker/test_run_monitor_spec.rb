require "spec_helper"

describe Worker::TestRunMonitor do
  subject(:worker) { described_class.new }

  it { is_expected.to be_a described_class }

  describe ".perform" do
    subject(:perform) { worker.perform(monitor_url, delay, data, web_url, timestamp) }

    before do
      stub_request(:any, %r{\Ahttps://(www|api).github.com/.*\z})
        .to_return(status: 200, body: response, headers: {})
      allow(SendSlackMessage).to receive(:new).and_return(ssm)
      allow(ssm).to receive(:update).and_return({ ts: "1595341466.004300" })
    end

    let(:monitor_url) { "https://api.github.com/repos/moj/project/job/123" }
    let(:delay) { 45 }
    let(:data) { { "channel" => "test", "user" => "test" } }
    let(:web_url) { "https://www.github.com/repos/moj/project/job/123" }
    let(:timestamp) { "1595341466.004300" }
    let(:response) { { 'status': "in_progress" }.to_json }
    let(:ssm) { instance_double("SendSlackMessage") }

    context "when the job has not completed" do
      it "creates a new MonitorTestRunWorker" do
        expect { perform }.to change(described_class.jobs, :size).by(1)
      end
    end

    context "when the job has completed" do
      let(:response) { { 'status': "completed" }.to_json }

      it "updates the slack message" do
        expect(ssm).to receive(:update).once
        perform
      end
    end
  end
end
