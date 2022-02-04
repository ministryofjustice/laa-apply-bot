require "rspec"

RSpec.describe Portal::NameErrorMessage do
  subject { described_class.call(names) }
  let(:names) { [one, two] }
  let(:one) { instance_double(Portal::Name, display_name: "TEST NAME", errors: "User TEST.NAME not known to CCMS") }
  let(:two) { instance_double(Portal::Name, display_name: "TEST TWO", errors: nil) }

  before do
    allow(Portal::Name).to receive(:new).with("test.name").and_return(one)
    allow(Portal::Name).to receive(:new).with("test two").and_return(two)
  end

  it { is_expected.to eq "*TEST NAME* :nope: User TEST.NAME not known to CCMS\n*TEST TWO* :yep:" }
end
