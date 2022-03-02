require "spec_helper"
require "rack/test"

describe "Sinatra App" do
  include Rack::Test::Methods

  def app
    App.new
  end

  it "displays home page" do
    get "/"
    expect(last_response.body).to include("LAA-Apply bot")
  end

  describe "#ping" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("BUILD_DATE").and_return(build_date)
      allow(ENV).to receive(:[]).with("BUILD_TAG").and_return(build_tag)
      get "/ping"
    end

    let(:build_date) { nil }
    let(:build_tag) { nil }

    context "when environment variables set" do
      let(:build_date) { "20150721" }
      let(:build_tag) { "test" }

      let(:expected_json) do
        {
          "build_date" => "20150721",
          "build_tag" => "test",
        }
      end

      it "returns JSON with app information" do
        expect(JSON.parse(last_response.body)).to eq(expected_json)
      end
    end

    context "when environment variables not set" do
      it 'returns "Not Available"' do
        expect(JSON.parse(last_response.body).values).to be_all("Not Available")
      end
    end

    it "returns ok http status" do
      expect(last_response.status).to eq 200
    end
  end

  describe "/interactive" do
    let(:ssm) { instance_double("SendSlackMessage") }

    before { allow(SendSlackMessage).to receive(:new).and_return(ssm) }

    context "when general data is posted to interactive" do
      let(:submitted_data) { { data: "something" } }

      it "is swallowed" do
        expect(SlackRubyBot::Client.logger).to receive(:warn).once
        post "/interactive", submitted_data
        expect(last_response.body).to eql ""
        expect(last_response.status).to eq 200
      end
    end

    context "when the data is a portal user response" do
      before do
        stub_request(:post, %r{\Ahttps://hooks.slack.com/actions/.*\z}).to_return(status: 200)
      end

      context "and they accept" do
        let(:submitted_data) do
          { "payload" =>
              '{"type":"block_actions","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},' \
              '"message":{"bot_id":"B011ZBY8UJ1",' \
              '"type":"message","text":"This content can\\u2019t be displayed.","user":"U011L1K39JT",' \
              '"ts":"1637072696.009000","team":"TQ22KT7EX","blocks":[{"type":"section","block_id":"Nr6lA",' \
              '"text":{"type":"mrkdwn","text":"These user names matched in CCMS","verbatim":false}},' \
              '{"type":"section","block_id":"user-script","text":{"type":"mrkdwn",' \
              '"text":"```dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov\\nchangetype: ' \
              'modify\\nadd: uniquemember\\nuniquemember: cn=FAKEUSER,cn=users,dc=lab,dc=gov```",' \
              '"verbatim":false}},{"type":"section","block_id":"Eh7M","text":{"type":"mrkdwn",' \
              '"text":"Send this script to the new_user channel?","verbatim":false}},{"type":"actions",' \
              '"block_id":"new_user_response","elements":[{"type":"button","action_id":"5ho","text":{' \
              '"type":"plain_text","text":"Approve","emoji":true},"style":"primary","value":"approve"},' \
              '{"type":"button","action_id":"ySNN","text":{"type":"plain_text","text":"Reject",' \
              '"emoji":true}, "style":"danger","value":"reject"}]}]},"state":{"values":{}},"response_url":' \
              '"https:\\/\\/hooks.slack.com\\/actions\\/ABCDE\\/123456\\/kjh4tkj34tkj34b6tkj",' \
              '"actions":[{"action_id":"5ho","block_id":"new_user_response","text":{"type":"plain_text",' \
              '"text":"Approve","emoji":true},"value":"approve","style":"primary","type":"button",' \
              '"action_ts":"1637072709.069557"}]}' }
        end

        it "a post to replace the text is made" do
          expect(ssm).to receive(:upload_file)
          post "/interactive", submitted_data
          expect(a_request(:post, %r{\Ahttps://hooks.slack.com/actions/.*\z})).to have_been_made.times(1)
        end
      end

      context "and they reject" do
        let(:submitted_data) do
          { "payload" =>
              '{"type":"block_actions","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},' \
              '"message":{"bot_id":"B011ZBY8UJ1",' \
              '"type":"message","text":"This content can\\u2019t be displayed.","user":"U011L1K39JT",' \
              '"ts":"1637072696.009000","team":"TQ22KT7EX","blocks":[{"type":"section","block_id":"Nr6lA",' \
              '"text":{"type":"mrkdwn","text":"These user names matched in CCMS","verbatim":false}},' \
              '{"type":"section","block_id":"user-script","text":{"type":"mrkdwn",' \
              '"text":"```dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov\\nchangetype: ' \
              'modify\\nadd: uniquemember\\nuniquemember: cn=FAKEUSER,cn=users,dc=lab,dc=gov```",' \
              '"verbatim":false}},{"type":"section","block_id":"Eh7M","text":{"type":"mrkdwn",' \
              '"text":"Send this script to the new_user channel?","verbatim":false}},{"type":"actions",' \
              '"block_id":"new_user_response","elements":[{"type":"button","action_id":"5ho","text":{' \
              '"type":"plain_text","text":"Approve","emoji":true},"style":"primary","value":"approve"},' \
              '{"type":"button","action_id":"ySNN","text":{"type":"plain_text","text":"Reject",' \
              '"emoji":true}, "style":"danger","value":"reject"}]}]},"state":{"values":{}},"response_url":' \
              '"https:\\/\\/hooks.slack.com\\/actions\\/ABCDE\\/123456\\/kjh4tkj34tkj34b6tkj",' \
              '"actions":[{"action_id":"5ho","block_id":"new_user_response","text":{"type":"plain_text",' \
              '"text":"Approve","emoji":true},"value":"reject","style":"primary","type":"button",' \
              '"action_ts":"1637072709.069557"}]}' }
        end

        it "a post to replace the text is made" do
          expect(ssm).not_to receive(:upload_file)
          post "/interactive", submitted_data
          expect(a_request(:post, %r{\Ahttps://hooks.slack.com/actions/.*\z})).to have_been_made.times(1)
        end
      end
    end
  end
end
