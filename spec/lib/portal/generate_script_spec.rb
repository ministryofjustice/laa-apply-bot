require 'rspec'

RSpec.describe Portal::GenerateScript do
  subject(:portal_script) { described_class.new(names) }

  context 'when a valid array of Portal::Name objects is passed' do
    let(:names) { [one] }
    let(:one) { instance_double(Portal::Name, portal_username: 'TEST%20NAME', display_name: 'TEST NAME') }
    let(:expected_output) do
      <<~SCRIPT.chomp
        dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov
        changetype: modify
        add: uniquemember
        uniquemember: cn=TEST NAME,cn=users,dc=lab,dc=gov
      SCRIPT
    end

    describe '.call' do
      subject(:call) { portal_script.call }

      it { is_expected.to eq expected_output }
    end

    describe '#call' do
      subject(:call) { described_class.call(names) }

      it { is_expected.to eq expected_output }
    end
  end
end
