require "spec_helper"

describe SlackApplybot::Bot do
  subject { described_class.instance }

  it_behaves_like "a slack ruby bot"
end
