module Helm
  module Messages
    class OTPModal < BaseMessage
      BASE_MESSAGE = {
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
        }
      }.freeze

      def initialize(service, script)
        super()
        @service = service
        @script = script
      end

      def self.call(service, script)
        new(service, script).call
      end

      def call
        result = []
        result << block("Thank you for confirming you wish to delete the following from *#{service}*:")
        result << block_with_id("```#{@script.join("\n")}```", "instances|#{service.downcase}|#{@script.join(';')}")
        result << input('otp', 'Please enter the OTP from your authenticator app below')
        BASE_MESSAGE.merge(blocks: result)
      end

      private

      def block_with_id(message, id)
        { 'block_id': id, 'type': 'section', 'text': { 'type': 'mrkdwn', 'text': message } }
      end

      def input(prefix, label)
        {
          'type': 'input',
          'block_id': "#{prefix}_response",
          'element': { 'type': 'plain_text_input', 'action_id': "#{prefix}_action", 'focus_on_load': true },
          'label': { 'type': 'plain_text', 'text': label, 'emoji': true }
        }
      end
    end
  end
end
