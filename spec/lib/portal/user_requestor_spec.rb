require "spec_helper"

RSpec.describe Portal::UserRequester do
  describe "initiate" do
    subject(:user_requester) { described_class.initiate(names, "channel") }

    let(:names) { "test1, test2, test3" }

    context "when all names are matched by portal" do
      before do
        class_double(Portal::NameValidator, call: true).as_stubbed_const
        instance_double(Portal::Names::Collator, matched_names: %w[TEST1 TEST2 TEST3],
                                                 unmatched_names: [])
      end

      it "expect the following calls to occur" do
        expect_any_instance_of(Portal::Messages::Failure).to_not receive(:call)
        expect_any_instance_of(Portal::Messages::Success).to receive(:call).once
        expect_any_instance_of(Portal::GenerateScript).to receive(:call).once
        expect_any_instance_of(SendSlackMessage).to receive(:generic).once
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
        expect_any_instance_of(Portal::Messages::Failure).to receive(:call).once
        expect_any_instance_of(Portal::Messages::Success).to_not receive(:call)
        expect_any_instance_of(Portal::GenerateScript).to_not receive(:call)
        expect_any_instance_of(SendSlackMessage).to receive(:generic).once
        user_requester
      end
    end
  end
end
