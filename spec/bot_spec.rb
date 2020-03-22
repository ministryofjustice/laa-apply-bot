require 'spec_helper'

describe SlackApplybot::Bot do
  subject { SlackApplybot::Bot.instance }

  it_behaves_like 'a slack ruby bot'
end
