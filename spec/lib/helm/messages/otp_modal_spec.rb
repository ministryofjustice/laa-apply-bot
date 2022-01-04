require 'spec_helper'

describe Helm::Messages::OTPModal do
  subject(:otp_modal_message) { described_class.call(service, %w[ap-1234 ap-2345]) }
  let(:service) { 'apply' }

  let(:expected_response) do
    {
      'title': {
        'type': 'plain_text',
        'text': 'ApplyBot - Helm deletion',
        'emoji': true
      },
      'submit': {
        'type': 'plain_text',
        'text': 'Confirm delete',
        'emoji': true
      },
      'type': 'modal',
      'close': {
        'type': 'plain_text',
        'text': 'Cancel',
        'emoji': true
      },
      'blocks': [
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': 'Thank you for confirming you wish to delete the following from *Apply*:'
          }
        },
        {
          'block_id': 'instances|apply|ap-1234;ap-2345',
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': "```ap-1234\nap-2345```"
          }
        },
        {
          'type': 'input',
          'block_id': 'otp_response',
          'element': {
            'type': 'plain_text_input',
            'action_id': 'otp_action',
            'focus_on_load': true
          },
          'label': {
            'type': 'plain_text',
            'text': 'Please enter the OTP from your authenticator app below',
            'emoji': true
          }
        }
      ]
    }
  end

  it { expect(otp_modal_message).to match_json_expression expected_response }

  context 'when a different service is passed' do
    let(:service) { 'cfe' }
    let(:expected_response) do
      {
        'title': {
          'type': 'plain_text',
          'text': 'ApplyBot - Helm deletion',
          'emoji': true
        },
        'submit': {
          'type': 'plain_text',
          'text': 'Confirm delete',
          'emoji': true
        },
        'type': 'modal',
        'close': {
          'type': 'plain_text',
          'text': 'Cancel',
          'emoji': true
        },
        'blocks': [
          {
            'type': 'section',
            'text': {
              'type': 'mrkdwn',
              'text': 'Thank you for confirming you wish to delete the following from *CFE*:'
            }
          },
          {
            'block_id': 'instances|cfe|ap-1234;ap-2345',
            'type': 'section',
            'text': {
              'type': 'mrkdwn',
              'text': "```ap-1234\nap-2345```"
            }
          },
          {
            'type': 'input',
            'block_id': 'otp_response',
            'element': {
              'type': 'plain_text_input',
              'action_id': 'otp_action',
              'focus_on_load': true
            },
            'label': {
              'type': 'plain_text',
              'text': 'Please enter the OTP from your authenticator app below',
              'emoji': true
            }
          }
        ]
      }
    end
    it { expect(otp_modal_message).to match_json_expression expected_response }
  end
end
