require "rspec"

RSpec.describe Portal::NameValidator do
  subject(:validate) { described_class.new(user) }

  context "when instantiated without a Portal::Name object" do
    let(:user) { "TEST.NAME" }

    it { expect { subject }.to raise_error(StandardError, "Name is invalid type") }
  end

  context "when instantiated without a Portal::Name object" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("PROVIDER_DETAILS_URL").and_return(dummy_provider_details_host)
      stub_request(:get, api_url).to_return(body: response_body, status: http_status)
    end

    let(:dummy_provider_details_host) { "http://my_dummy_url/" }
    let(:api_url) { "#{dummy_provider_details_host}#{user.portal_username}" }
    let(:response_body) { sarah_smith_response.to_json }
    let(:http_status) { 200 }
    let(:user) { Portal::Name.new("test.user") }
    describe "#call" do
      subject(:call_validate) { validate.call }

      it do
        expect { call_validate }.to change { user.portal_name_valid }.to true
      end

      describe "error handling" do
        context "user adds non-ascii characters to their name" do
          # we suspect that this comes from a cut and paste from MS into
          # the login box when parsed it returns BRAND%20NEW\u2011USER
          let(:user) { Portal::Name.new("brand new‒user") }
          let(:response_body) { sarah_smith_response.to_json }
          let(:http_status) { 200 }
          let(:error_message) { "'BRAND NEW‒USER' contains unicode characters, please re-type if cut and pasted" }

          it { expect { call_validate }.to change { user.portal_name_valid }.to false }
          it { expect { call_validate }.to change { user.errors }.to error_message }
        end

        context "username not on provider details api" do
          let(:response_body) { user_not_found_response.to_json }
          let(:http_status) { 404 }

          it "responds false" do
            expect(subject).to be false
          end

          it { expect { call_validate }.to change { user.portal_name_valid }.to false }
          it { expect { call_validate }.to change { user.errors }.to "User TEST.USER not known to CCMS" }
        end

        context "other non-200 response" do
          let(:response_body) { "" }
          let(:http_status) { 505 }
          it "responds false" do
            expect(subject).to be false
          end
        end
      end
    end

    describe ".call" do
      subject(:call) { described_class.call(user) }

      let(:user) { Portal::Name.new("test.user") }

      it do
        expect { call }.to change { user.portal_name_valid }.to true
      end
    end
  end

  def sarah_smith_response
    {
      "providerFirmId" => 24_493,
      "contactUserId" => 47_096,
      "contacts" => [
        { "id" => 3_043_807, "name" => "NAME.ONE" },
        { "id" => 3_178_792, "name" => "DJXANKAZTAL" }
      ],
      "feeEarners" => [],
      "providerOffices" => [{ "id" => "81333", "name" => "LOCAL LAW & CO LTD-8B869F" }]
    }
  end

  def user_not_found_response
    {
      "timestamp" => "2020-07-28T10:52:01.141+0000",
      "status" => 404,
      "error" => "Not Found",
      "message" => "No records found for [SARAH%20SMITH]",
      "path" => "/api/providerDetails/SARAH%20SMITH"
    }
  end
end
