require "spec_helper"
require "date_display"

describe DateDisplay do
  subject(:date_display) { described_class.new(date) }

  let(:date) { Date.today }

  it { is_expected.to be_a DateDisplay }

  describe ".call" do
    subject(:call) { date_display.call }

    context "when passed today" do
      it { is_expected.to eq "today" }
    end

    context "when passed yesterday " do
      let(:date) { Date.yesterday }

      it { is_expected.to eq "yesterday" }
    end

    context "when passed the day before yesterday " do
      let(:date) { Date.today - 2.days }

      it { is_expected.to eq "2 days ago" }
    end
  end

  describe "#call" do
    subject(:call) { described_class.call(date) }

    it { is_expected.to eq "today" }
  end
end
