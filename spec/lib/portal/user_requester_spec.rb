require "spec_helper"

RSpec.describe Portal::UserRequester do
  describe "initiate" do
    subject(:user_requester) { described_class.initiate(names, "channel") }

    let(:names) { "test1, test2, test3" }
    let(:ssm) { instance_double("SendSlackMessage") }
    let(:pm_failure) { instance_double("Portal::Messages::Failure") }
    let(:pm_success) { instance_double("Portal::Messages::Success") }
    let(:pm_generate_script) { instance_double("Portal::GenerateScript") }

    before do
      allow(SendSlackMessage).to receive(:new).and_return(ssm)
      allow(Portal::Messages::Failure).to receive(:new).and_return(pm_failure)
      allow(Portal::Messages::Success).to receive(:new).and_return(pm_success)
      allow(Portal::GenerateScript).to receive(:new).and_return(pm_generate_script)
    end

    context "when all names are matched by portal" do
      before do
        class_double(Portal::NameValidator, call: true).as_stubbed_const
        instance_double(Portal::Names::Collator, matched_names: %w[TEST1 TEST2 TEST3],
                                                 unmatched_names: [])
      end

      it "expect the following calls to occur" do
        expect(pm_failure).not_to receive(:call)
        expect(pm_success).to receive(:call).once
        expect(pm_generate_script).to receive(:call).once
        expect(ssm).to receive(:generic).once
        user_requester
      end
    end

    context "when no names are matched by portal" do
      before do
        class_double(Portal::NameValidator, call: false).as_stubbed_const
        instance_double(Portal::Names::Collator, matched_names: [],
                                                 unmatched_names: %w[TEST1 TEST2 TEST3])
      end

      it "expect the following calls to occur" do
        expect(pm_failure).to receive(:call).once
        expect(pm_success).not_to receive(:call)
        expect(pm_generate_script).not_to receive(:call)
        expect(ssm).to receive(:generic).once
        user_requester
      end
    end
  end
end
