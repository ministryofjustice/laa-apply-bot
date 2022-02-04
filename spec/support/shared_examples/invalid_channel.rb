RSpec.shared_examples "the channel is invalid" do
  let!(:client) { SlackRubyBot::App.new.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  let(:params) { Hashie::Mash.new(text: user_input, channel:, user: "user") }
  let(:channel) { "dangerous" }
  let(:expected_response) { "Sorry <@user>, I don't understand that command!" }
  let(:expected_hash) do
    { channel: channel, as_user: true, text: "Sorry <@user>, I don't understand that command!" }
  end

  it "raises a message-sending error" do
    expect_any_instance_of(SendSlackMessage).to receive(:generic).with(expected_hash)
    expect { message_hook.call(client, params) }.to raise_error ChannelValidity::PublicError
  end
end
