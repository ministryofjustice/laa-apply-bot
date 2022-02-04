require "spec_helper"

RSpec.describe Slack::BlockBuilder do
  subject(:block_builder) { described_class.new }

  let(:args) { {} }

  it { is_expected.to be_a Slack::BlockBuilder }

  describe "#call" do
    subject(:class_call) { described_class.call(state, **args) }
    let(:state) { :start }

    it { is_expected.to be_a Hash }
  end

  describe ".call" do
    subject(:call) { block_builder.call(state, **args) }

    context "when the state is missing" do
      let(:state) { nil }

      it { expect { call }.to raise_error("State error") }
    end

    context "when the state is valid" do
      let(:state) { :start }
      let(:expected_result) do
        {
          blocks:
            [{
              type: "section",
              block_id: "start",
              text:
                {
                  type: "mrkdwn",
                  text: ":spinner2: A test run has been requested from Github"
                }
            }]
        }
      end

      it { expect(call[:blocks].count).to eql 1 }
      it { expect(call).to match(expected_result) }
    end

    context "when the state is searching" do
      let(:state) { :searching }

      it { expect(call[:blocks].count).to eql 1 }
    end

    context "when the state is waiting" do
      let(:state) { :waiting }
      let(:args) { { web_url: "http://github.com/test" } }
      let(:expected_result) do
        {
          blocks:
          [
            {
              type: "section",
              block_id: "waiting",
              text:
                {
                  type: "mrkdwn",
                  text: ":spinner2: The tests are running.\n I'll update you on completion, "\
                        "or you can click on <http://github.com/test|this link> for details"
                }
            },
          ]
        }
      end

      it { expect(call[:blocks].count).to eql 1 }
      it { expect(call).to match(expected_result) }
    end

    context "when the state is complete" do
      let(:state) { :complete }

      it { expect(call[:blocks].count).to eql 1 }
    end
  end

  describe "#start_error" do
    subject(:error_call) { described_class.start_error("this is an error message") }
    let(:expected_result) do
      {
        blocks:
          [
            {
              type: "section",
              block_id: "error",
              text:
                {
                  type: "mrkdwn",
                  text: "Could not trigger job on Github ```this is an error message```"
                }
            },
          ]
      }
    end

    it { expect(error_call[:blocks].count).to eql 1 }
    it { expect(error_call).to match(expected_result) }
  end

  describe "#timeout_error" do
    subject(:error_call) { described_class.timeout_error }
    let(:expected_result) do
      {
        blocks:
          [
            {
              type: "section",
              block_id: "error",
              text:
                {
                  type: "mrkdwn",
                  text: ":nope: It's been over two minutes, you'll need to check github manually"
                }
            },
          ]
      }
    end

    it { expect(error_call[:blocks].count).to eql 1 }
    it { expect(error_call).to match(expected_result) }
  end
end
