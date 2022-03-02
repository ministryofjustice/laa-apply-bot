require "rspec"

RSpec.describe Worker::TestRunLocate do
  subject(:worker) { described_class.new }

  before { allow(ENV).to receive(:[]).and_call_original }

  it { is_expected.to be_a described_class }

  describe ".perform" do
    subject(:perform) { worker.perform("channel", "000.000", iteration, etag) }

    before do
      stub_request(:get, %r{\Ahttps://(www|api).github.com/.*/runs.*\z})
        .to_return(status:, body: response, headers: {})
      allow(SendSlackMessage).to receive(:new).and_return(ssm)
      allow(ssm).to receive(:update).and_return({ ts: "1595341466.004300" })
    end

    let(:response) { { 'total_count': 1 }.to_json }
    let(:ssm) { instance_double("SendSlackMessage") }
    let(:status) { 200 }
    let(:iteration) { 1 }
    let(:etag) { nil }

    context "when github has an in progress job" do
      before do
        allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(5)
        stub_request(:get, "#{GithubValues.repo_url}/actions/runs/30433642/jobs")
          .to_return(status:, body: job_response, headers: {})
      end

      let(:response) do
        {
          'total_count': 1,
          'workflow_runs': [
            {
              'html_url': "https://github.com/repos/#{ENV['GITHUB_OWNER']}/#{ENV['GITHUB_REPO']}/actions/runs/30433642",
              'jobs_url': "#{GithubValues.repo_url}/actions/runs/30433642/jobs",
            },
          ],
        }.to_json
      end

      let(:job_response) do
        {
          'total_count': 1,
          'jobs': [
            {
              'html_url': web_url,
            },
          ],
        }.to_json
      end

      let(:iteration) { 2 }
      let(:web_url) { "https://github.com/repos/#{ENV['GITHUB_OWNER']}/#{ENV['GITHUB_REPO']}/runs/399444496" }
      let(:expected_hash) do
        {
          as_user: true,
          channel: "channel",
          blocks: [
            {
              block_id: "waiting",
              text:
                {
                  text: ":spinner2: The tests are running.\n I'll update you on completion, or you can "\
                        "click on <#{web_url}?check_suite_focus=true|this link> for details",
                  type: "mrkdwn",
                },
              type: "section",
            },
          ],
          ts: "000.000",
        }
      end

      it "sends an update command to slack with a progress message" do
        expect(ssm).to receive(:update).with(expected_hash)
        perform
      end

      it "creates a new MonitorTestRunWorker" do
        expect { perform }.to change(Worker::TestRunMonitor.jobs, :size).by(1)
      end
    end

    context "when github does not have any in progress jobs" do
      before { allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(5) }

      let(:iteration) { 2 }

      let(:expected_hash) do
        {
          as_user: true,
          channel: "channel",
          blocks: [
            {
              block_id: "searching",
              text:
                {
                  text: ":spinner2: A test run has been requested from Github. Time spent looking so far: 10 seconds",
                  type: "mrkdwn",
                },
              type: "section",
            },
          ],
          ts: "000.000",
        }
      end

      let(:response) { { 'total_count': 0 }.to_json }

      it "sends an update command to slack with a timeout message" do
        expect(ssm).to receive(:update).with(expected_hash)
        perform
      end

      it "creates a new TestRunLocateWorker" do
        expect { perform }.to change(described_class.jobs, :size).by(1)
      end
    end

    context "when github does not respond as expected" do
      before { allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(5) }

      let(:iteration) { 2 }

      let(:expected_hash) do
        {
          as_user: true,
          channel: "channel",
          blocks: [
            {
              block_id: "searching",
              text:
              {
                text: ":spinner2: A test run has been requested from Github. Time spent looking so far: 10 seconds",
                type: "mrkdwn",
              },
              type: "section",
            },
          ],
          ts: "000.000",
        }
      end
      let(:status) { 204 }
      let(:response) { { 'unexpected_value': 0 }.to_json }

      it "sends an update command to slack with a timeout message" do
        expect(ssm).to receive(:update).with(expected_hash)
        perform
      end
    end

    describe "when the iteration count indicates a timeout" do
      before { allow(ENV).to receive(:[]).with("GITHUB_WAIT_SECONDS").and_return(61) }

      let(:iteration) { 2 }
      let(:expected_hash) do
        {
          as_user: true,
          channel: "channel",
          blocks: [
            {
              block_id: "error",
              text:
                {
                  text: ":nope: It's been over two minutes, you'll need to check github manually",
                  type: "mrkdwn",
                },
              type: "section",
            },
          ],
          ts: "000.000",
        }
      end

      it "sends an update command to slack with a timeout message" do
        expect(ssm).to receive(:update).with(expected_hash)
        perform
      end
    end
  end
end
