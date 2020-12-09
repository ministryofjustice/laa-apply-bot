require 'rspec'

RSpec.describe Portal::Name do
  subject(:portal_name) { described_class.new(name) }

  let(:name) { 'test.name' }

  describe '#build' do
    subject(:build) { portal_name.build }

    context 'name is text' do
      let(:expected_hash) do
        {
          original_name: 'test.name',
          display_name: 'TEST.NAME',
          portal_username: 'TEST.NAME',
          portal_name_valid: nil,
          errors: nil
        }
      end

      it { expect(build.as_json.symbolize_keys).to eq expected_hash }
    end

    context 'name has a space' do
      let(:name) { 'test name' }
      let(:expected_hash) do
        {
          original_name: 'test name',
          display_name: 'TEST NAME',
          portal_username: 'TEST%20NAME',
          portal_name_valid: nil,
          errors: nil
        }
      end

      it { expect(build.as_json.symbolize_keys).to eq expected_hash }
    end

    context 'name is an email' do
      let(:name) { 'test.name@example.com' }
      let(:expected_hash) do
        {
          original_name: 'test.name@example.com',
          display_name: 'TEST.NAME@EXAMPLE.COM',
          portal_username: 'TEST.NAME@EXAMPLE.COM',
          portal_name_valid: nil,
          errors: nil
        }
      end

      it { expect(build.as_json.symbolize_keys).to eq expected_hash }
    end

    context 'name is a slack parsed email' do
      let(:name) { '<MAILTO:test.name@example.com|test.name@example.com>' }
      let(:expected_hash) do
        {
          original_name: 'test.name@example.com',
          display_name: 'TEST.NAME@EXAMPLE.COM',
          portal_username: 'TEST.NAME@EXAMPLE.COM',
          portal_name_valid: nil,
          errors: nil
        }
      end

      it { expect(build.as_json.symbolize_keys).to eq expected_hash }
    end
  end
end
