require 'rspec'

RSpec.describe Portal::Orchestrator do
  subject(:orchestrator) { described_class.new(user_array, data) }
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:data) { { 'user' => 'user', 'channel' => channel } }
  let(:channel) { 'shared_channel' }
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: 'shared_channel'
      }
    }.to_json
  end
  let(:user_array) { ['test.one', 'test two'] }
  let(:notify_message) { 'Done, I have raised a request in the #shared_channel channel' }
  let(:expected_message) do
    '<!here> can you add the following users? <@user> has raised the request and the apply service is ready for them'
  end
  it { is_expected.to be_a(Portal::Orchestrator) }

  describe '.compose' do
    subject(:compose) { described_class.compose(user_array, data) }
    let(:expected_response) do
      <<~RESPONSE.chomp
        dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov
        changetype: modify
        add: uniquemember
        uniquemember: cn=TEST.ONE,cn=users,dc=lab,dc=gov
        uniquemember: cn=TEST TWO,cn=users,dc=lab,dc=gov
      RESPONSE
    end
    let(:notify_hash) { { channel: channel, as_user: true, text: notify_message } }
    let(:output_hash) do
      {
        channels: 'shared_channel',
        content: expected_response,
        filename: 'output.ldif',
        initial_comment: expected_message
      }
    end
    before { class_double(Portal::NameValidator, call: true).as_stubbed_const }

    it 'sends a file_upload message' do
      expect_any_instance_of(SendSlackMessage).to receive(:upload_file).with(output_hash)
      compose
    end

    it 'does not alert the user in the requesting channel' do
      expect_any_instance_of(SendSlackMessage).to_not receive(:generic).with(notify_hash)
      compose
    end

    context 'when the user raises the request outside the expected channel' do
      subject(:compose) { described_class.compose(user_array, data) }
      let(:channel) { 'channel' }
      let(:notify_hash) { { channel: channel, as_user: true, text: notify_message } }
      let(:output_channel) { instance_double(Portal::OutputChannel, valid?: false) }

      before do
        allow(Portal::OutputChannel).to receive(:new).with(channel).and_return(output_channel)
      end

      it 'alerts the user in the requesting channel' do
        expect_any_instance_of(SendSlackMessage).to receive(:generic).with(notify_hash)
        compose
      end

      it 'sends a file_upload message to the expected channel' do
        expect_any_instance_of(SendSlackMessage).to receive(:upload_file).with(output_hash)
        compose
      end
    end

    context 'when a name has failed to validate' do
      let(:user_array) { ['test.name', 'test two'] }
      let(:expected_hash) do
        {
          as_user: true,
          channel: 'shared_channel',
          text: error_message
        }
      end
      let(:error_message) { "*TEST NAME* :nope: User TEST.NAME not known to CCMS\n*TEST TWO* :yep:" }
      before do
        allow(Portal::NameErrorMessage).to receive(:call).and_return(error_message)
        class_double(Portal::NameValidator, call: false).as_stubbed_const
      end

      it 'sends a text message' do
        expect_any_instance_of(SendSlackMessage).to receive(:generic).with(expected_hash)
        compose
      end
    end
  end
end
