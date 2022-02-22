require "rspec"

RSpec.describe Worker::TestRunStart do
  subject(:worker) { described_class.new }

  before do
    stub_user = Struct.new(:id, :real_name)
    stub_request(:post, %r{\Ahttps://(www|api).github.com/.*/dispatches\z}).to_return(response)
    allow_any_instance_of(SendSlackMessage).to receive(:user)
      .and_return(stub_user.new({ id: "AB123CDEF", real_name: "test user" }))
    allow_any_instance_of(SendSlackMessage).to receive(:generic).and_return({ ts: "1595341466.004300" })
  end

  let(:slack_user_response) { { status: 200, body: { id: "UQ785LQGH", real_name: "test user" }.to_json, headers: {} } }
  let(:response) { good_response }
  let(:good_response) { { status: 204, body: "", headers: {} } }
  let(:bad_response) { { status: 422, body: "", headers: {} } }

  it { is_expected.to be_a described_class }

  describe ".perform" do
    subject(:perform) { worker.perform(data) }

    let(:data) { { "channel" => "test", "user" => "test" } }

    context "when the job is successfully started in github and located" do
      it "polls github for data" do
        perform
        expect(a_request(:post, "https://api.github.com/repos/moj/project/dispatches")).to have_been_made.times(1)
      end

      it "sends a slack message" do
        expect_any_instance_of(SendSlackMessage).to receive(:generic)
        perform
      end

      it "creates a new MonitorTestRunWorker" do
        expect { perform }.to change(Worker::TestRunLocate.jobs, :size).by(1)
      end
    end

    context "when the job cannot be started in github" do
      let(:response) { bad_response }
      let(:expected_hash) do
        {
          as_user: true,
          channel: "test",
          blocks: [
            {
              block_id: "error",
              text:
                {
                  text: "Could not trigger job on Github ```422 Unprocessable Entity```",
                  type: "mrkdwn",
                },
              type: "section",
            },
          ],
        }
      end

      it "polls github for data" do
        expect_any_instance_of(SendSlackMessage).to receive(:generic).with(expected_hash)
        perform
      end
    end
  end
end
