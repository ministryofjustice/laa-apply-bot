require 'spec_helper'
require 'rack/test'

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'displays home page' do
    get '/'
    expect(last_response.body).to include('LAA-Apply bot')
  end

  describe '#ping' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('BUILD_DATE').and_return(build_date)
      allow(ENV).to receive(:[]).with('BUILD_TAG').and_return(build_tag)
      get '/ping'
    end
    let(:build_date) { nil }
    let(:build_tag) { nil }

    context 'when environment variables set' do
      let(:build_date) { '20150721' }
      let(:build_tag) { 'test' }

      let(:expected_json) do
        {
          'build_date' => '20150721',
          'build_tag' => 'test'
        }
      end

      it 'returns JSON with app information' do
        expect(JSON.parse(last_response.body)).to eq(expected_json)
      end
    end

    context 'when environment variables not set' do
      it 'returns "Not Available"' do
        expect(JSON.parse(last_response.body).values).to be_all('Not Available')
      end
    end

    it 'returns ok http status' do
      expect(last_response.status).to eq 200
    end
  end

  describe '/interactive' do
    context 'when general data is posted to interactive' do
      let(:submitted_data) { { data: 'something' } }

      it 'is swallowed' do
        expect(SlackRubyBot::Client.logger).to receive(:warn).once
        post '/interactive', submitted_data
        expect(last_response.body).to eql ''
        expect(last_response.status).to eq 200
      end
    end

    context 'when the data is a portal user response' do
      before do
        stub_request(:post, %r{\Ahttps://hooks.slack.com/actions/.*\z}).to_return(status: 200)
      end

      context 'and they accept' do
        let(:submitted_data) do
          { 'payload' =>
              '{"type":"block_actions","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},' \
              '"message":{"bot_id":"B011ZBY8UJ1",' \
              '"type":"message","text":"This content can\\u2019t be displayed.","user":"AB123DEFG",' \
              '"ts":"1637072696.009000","team":"ABCDE","blocks":[{"type":"section","block_id":"Nr6lA",' \
              '"text":{"type":"mrkdwn","text":"These user names matched in CCMS","verbatim":false}},' \
              '{"type":"section","block_id":"user-script","text":{"type":"mrkdwn",' \
              '"text":"```dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov\\nchangetype: ' \
              'modify\\nadd: uniquemember\\nuniquemember: cn=FAKEUSER,cn=users,dc=lab,dc=gov```",' \
              '"verbatim":false}},{"type":"section","block_id":"Eh7M","text":{"type":"mrkdwn",' \
              '"text":"Send this script to the new_user channel?","verbatim":false}},{"type":"actions",' \
              '"block_id":"new_user_response","elements":[{"type":"button","action_id":"approve","text":{' \
              '"type":"plain_text","text":"Approve","emoji":true},"style":"primary","value":"approve"},' \
              '{"type":"button","action_id":"reject","text":{"type":"plain_text","text":"Reject",' \
              '"emoji":true}, "style":"danger","value":"reject"}]}]},"state":{"values":{}},"response_url":' \
              '"https:\\/\\/hooks.slack.com\\/actions\\/ABCDE\\/123456\\/kjh4tkj34tkj34b6tkj",' \
              '"actions":[{"action_id":"approve","block_id":"new_user_response","text":{"type":"plain_text",' \
              '"text":"Approve","emoji":true},"value":"approve","style":"primary","type":"button",' \
              '"action_ts":"1637072709.069557"}]}' }
        end

        it 'a post to replace the text is made' do
          expect_any_instance_of(SendSlackMessage).to receive(:upload_file)
          post '/interactive', submitted_data
        end
      end

      context 'and they reject' do
        let(:submitted_data) do
          { 'payload' =>
              '{"type":"block_actions","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},' \
              '"message":{"bot_id":"B011ZBY8UJ1",' \
              '"type":"message","text":"This content can\\u2019t be displayed.","user":"AB123DEFG",' \
              '"ts":"1637072696.009000","team":"ABCDE","blocks":[{"type":"section","block_id":"Nr6lA",' \
              '"text":{"type":"mrkdwn","text":"These user names matched in CCMS","verbatim":false}},' \
              '{"type":"section","block_id":"user-script","text":{"type":"mrkdwn",' \
              '"text":"```dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov\\nchangetype: ' \
              'modify\\nadd: uniquemember\\nuniquemember: cn=FAKEUSER,cn=users,dc=lab,dc=gov```",' \
              '"verbatim":false}},{"type":"section","block_id":"Eh7M","text":{"type":"mrkdwn",' \
              '"text":"Send this script to the new_user channel?","verbatim":false}},{"type":"actions",' \
              '"block_id":"new_user_response","elements":[{"type":"button","action_id":"approve","text":{' \
              '"type":"plain_text","text":"Approve","emoji":true},"style":"primary","value":"approve"},' \
              '{"type":"button","action_id":"reject","text":{"type":"plain_text","text":"Reject",' \
              '"emoji":true}, "style":"danger","value":"reject"}]}]},"state":{"values":{}},"response_url":' \
              '"https:\\/\\/hooks.slack.com\\/actions\\/ABCDE\\/123456\\/kjh4tkj34tkj34b6tkj",' \
              '"actions":[{"action_id":"reject","block_id":"new_user_response","text":{"type":"plain_text",' \
              '"text":"Approve","emoji":true},"value":"reject","style":"primary","type":"button",' \
              '"action_ts":"1637072709.069557"}]}' }
        end

        it 'a post to replace the text is made' do
          expect_any_instance_of(SendSlackMessage).to_not receive(:upload_file)
          post '/interactive', submitted_data
        end
      end
    end

    context 'when the data is clicking on delete a single branch for apply' do
      before do
        allow_any_instance_of(SendSlackMessage).to receive(:open_modal).and_return({})
      end
      let(:submitted_data) do
        { 'payload' =>
            '{"type":"block_actions","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},' \
            '"message":{"bot_id":"B011ZBY8UJ1",' \
            '"type":"message","text":"This content can\\u2019t be displayed.","user":"AB123DEFG",' \
            '"ts":"1640347813.007300","team":"ABCDE","blocks":[{"type":"section","text":{"type": "plain_text",' \
            '"text":"snipped out block section.","emoji":true}}]},"state":{"values":{}},"response_url":' \
            '"https:\\/\\/hooks.slack.com\\/actions\\/ABCDE\\/123456\\/kjh4tkj34tkj34b6tkj",' \
            '"actions":[{"action_id":"delete_branch","block_id":"delete_branch|apply|branch-to-delete",' \
            '"text":{"type":"plain_text","text":"Delete branch-to-delete","emoji":true},"value":' \
            '"branch-to-delete","type":"button","action_ts":"1640350290.036218"}]}' }
      end

      it 'expect only logging to happen - for now' do
        expect(Helm::Messages::OTPModal).to receive(:call).once
        expect_any_instance_of(SendSlackMessage).to receive(:open_modal).once
        post '/interactive', submitted_data
      end
    end

    context 'when the user enters a OTP and submits to confirm' do
      let(:submitted_data) do
        { 'payload' =>
            '{"type":"view_submission","user":{"id":"AB123DEFG","username":"test.user","name":"test.user"},'\
            '"trigger_id":"2881259344611.818087925507.655d3902f892a83c2d73b6d901fb327a",' \
            '"view":{"id":"V02RX6GFA90","team_id":"TQ22KT7EX","type":"modal","blocks":[{"type":"section","block_id"' \
            ':"SA8=5","text":{"type":"mrkdwn",' \
            '"text":"Thank you for confirming you wish to delete the following from *Apply*:",":verbatim":false}},' \
            '{"type":"section", "block_id":"instances|apply|ap-1234", '\
            '"text":{"type":"mrkdwn", "text":"```ap-1234```","verbatim":' \
            'false}},{"type":"input","block_id":"otp_response","label":{"type":"plain_text", "text":' \
            '"Please enter the OTP from your authenticator app below", "emoji":true},"optional":false,' \
            '"dispatch_action":false,"element":{"type":"plain_text_input", "action_id":"otp_action", ' \
            '"dispatch_action_config":{"trigger_actions_on":["on_enter_pressed"]}}}],"state":{"values":{ ' \
            '"otp_response":{"otp_action":{"type":"plain_text_input", "value":"123456"}}}},"hash":' \
            '"1640353401.23V2Q15R","title":{"type":"plain_text","text":"ApplyBot - Helm deletion",' \
            '"emoji":true},"clear_on_close":false,"notify_on_close":false,"close":{"type":"plain_text", ' \
            '"text":"Cancel", "emoji":true},"submit":{"type":"plain_text", "text":"Confirm delete", "emoji":true}}}' }
      end

      context 'when the otp_validation fails' do
        before { allow_any_instance_of(OTP::Validate).to receive(:call).and_return({ valid: false, message: 'fail' }) }

        it 'sends a new open_modal call' do
          expect(Helm::Delete).to_not receive(:call)
          expect_any_instance_of(SendSlackMessage).to receive(:open_modal).once
          post '/interactive', submitted_data
        end
      end

      context 'when the otp_validation succeeds' do
        before { allow_any_instance_of(OTP::Validate).to receive(:call).and_return({ valid: true, message: nil }) }

        context 'and the delete attempt fails' do
          it 'sends a new open_modal call' do
            expect(Helm::Delete).to receive(:call).once
            post '/interactive', submitted_data
          end
        end

        context 'and the delete attempt succeeds' do
          before { allow(Helm::Delete).to receive(:call).and_return(true) }

          it 'sends a new open_modal call' do
            expect(Helm::Delete).to receive(:call).once
            # expect(OTP::Validate).to receive(:call).once.and_return({ valid: true, message: nil })
            expect_any_instance_of(SendSlackMessage).to receive(:open_modal).once
            post '/interactive', submitted_data
          end
        end
      end
    end
  end
end
