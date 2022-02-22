require "spec_helper"

RSpec.describe Portal::Names::Collator do
  subject(:collator) { described_class.new(names) }

  before do
    allow(Portal::Name).to receive(:new).with("TEST.NAME").and_return(one)
    allow(Portal::Name).to receive(:new).with("TEST TWO").and_return(two)
    allow(Portal::Name).to receive(:new).with("TEST").and_return(three)
    class_double(Portal::NameValidator, call: true).as_stubbed_const
  end

  let(:names) { "test two,test.name ,test" }
  let(:one) do
    instance_double(Portal::Name, display_name: "TEST NAME",
                                  portal_username: "TEST NAME",
                                  errors: "User TEST.NAME not known to CCMS")
  end
  let(:two) { instance_double(Portal::Name, display_name: "TEST TWO", portal_username: "TEST TWO", errors: nil) }
  let(:three) { instance_double(Portal::Name, display_name: "THREE", portal_username: "THREE", errors: nil) }

  it { is_expected.to respond_to :matched_names }
  it { is_expected.to respond_to :unmatched_names }

  describe ".matched_names" do
    subject(:matched_names) { collator.matched_names }

    it "returns an array of name objects" do
      expect(matched_names).to be_a Array
    end
  end

  describe ".unmatched_names" do
    subject(:unmatched_names) { collator.unmatched_names }

    before do
      class_double(Portal::NameValidator, call: false).as_stubbed_const
    end

    it "returns an array of name objects" do
      expect(unmatched_names).to be_a Array
    end
  end
end
