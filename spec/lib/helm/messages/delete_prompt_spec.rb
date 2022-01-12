require 'spec_helper'

describe Helm::Messages::DeletePrompt do
  subject(:delete_prompt_message) { described_class.call('apply', %w[ap-1234 ap-2345], deleted) }

  let(:deleted) { nil }
  let(:expected_response) do
    [
      {
        'type': 'section',
        'text': {
          'type': 'mrkdwn',
          'text': 'No branches or pull requests can be found for the following instances in *Apply*'
        }
      },
      {
        'type': 'section',
        'text': {
          'type': 'mrkdwn',
          'text': 'Either delete them individually below (you will need to enter a OTP for each button clicked)'
        }
      },
      {
        'type': 'section',
        'block_id': 'delete_branch|apply|ap-1234',
        'text': {
          'type': 'mrkdwn',
          'text': 'ap-1234'
        },
        'accessory': {
          'type': 'button',
          'text': {
            'type': 'plain_text',
            'text': 'Delete ap-1234',
            'emoji': true
          },
          'value': 'ap-1234',
          'action_id': 'delete_branch'
        }
      },
      {
        'type': 'section',
        'block_id': 'delete_branch|apply|ap-2345',
        'text': {
          'type': 'mrkdwn',
          'text': 'ap-2345'
        },
        'accessory': {
          'type': 'button',
          'text': {
            'type': 'plain_text',
            'text': 'Delete ap-2345',
            'emoji': true
          },
          'value': 'ap-2345',
          'action_id': 'delete_branch'
        }
      }
    ]
  end

  it { expect(delete_prompt_message).to match_json_expression expected_response }

  context 'when passed an array with already deleted contexts' do
    let(:deleted) { %w[ap-2345] }
    let(:expected_response) do
      [
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': 'No branches or pull requests can be found for the following instances in *Apply*'
          }
        },
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': 'Either delete them individually below (you will need to enter a OTP for each button clicked)'
          }
        },
        {
          'type': 'section',
          'block_id': 'delete_branch|apply|ap-1234',
          'text': {
            'type': 'mrkdwn',
            'text': 'ap-1234'
          },
          'accessory': {
            'type': 'button',
            'text': {
              'type': 'plain_text',
              'text': 'Delete ap-1234',
              'emoji': true
            },
            'value': 'ap-1234',
            'action_id': 'delete_branch'
          }
        },
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': '~ap-2345~'
          }
        }
      ]
    end

    it { expect(delete_prompt_message).to match_json_expression expected_response }
  end
end
