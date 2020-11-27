require 'rspec'

RSpec.describe Portal::Orchestrator do
  subject(:orchestrator) { described_class.new(user_array, 'channel') }

  let(:user_array) { ['test.one', 'test two'] }

  it { is_expected.to be_a(Portal::Orchestrator) }

  describe '.compose' do
    subject(:compose) { described_class.compose(user_array, 'channel') }
    let(:expected_response) do
      <<~RESPONSE.chomp
        dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov
        changetype: modify
        add: uniquemember
        uniquemember: cn=TEST.ONE,cn=users,dc=lab,dc=gov
        uniquemember: cn=TEST TWO,cn=users,dc=lab,dc=gov
      RESPONSE
    end
    let(:expected_hash) { { channels: 'channel', content: expected_response, filename: 'output.ldif' } }
    before { class_double(Portal::NameValidator, call: true).as_stubbed_const }

    it 'sends a file_upload message' do
      expect_any_instance_of(SendSlackMessage).to receive(:upload_file).with(expected_hash)
      compose
    end

    context 'when a name has failed to validate' do
      let(:user_array) { ['test.name', 'test two'] }
      let(:expected_hash) do
        {
          as_user: true,
          channel: 'channel',
          text: "*TEST NAME* :nope: User TEST.NAME not known to CCMS\n*TEST TWO* :yep:"
        }
      end
      let(:one) { instance_double(Portal::Name, display_name: 'TEST NAME', errors: 'User TEST.NAME not known to CCMS') }
      let(:two) { instance_double(Portal::Name, display_name: 'TEST TWO', errors: nil) }
      before do
        allow(Portal::Name).to receive(:new).with('test.name').and_return(one)
        allow(Portal::Name).to receive(:new).with('test two').and_return(two)
        class_double(Portal::NameValidator, call: false).as_stubbed_const
      end

      it 'sends a text message' do
        expect_any_instance_of(SendSlackMessage).to receive(:generic).with(expected_hash)
        compose
      end
    end
  end
end
