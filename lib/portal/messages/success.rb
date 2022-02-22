module Portal
  module Messages
    class Success
      def initialize(script)
        @script = script
      end

      def self.call(script)
        new(script).call
      end

      def call
        result = []
        result << block("These user names matched in CCMS")
        result << block_with_id("```#{@script}```", "user-script")
        result << block("Send this script to the new_user channel?")
        result << action_block("new_user_response") { buttons }
        result
      end

      private

      def block(message)
        { 'type': "section", 'text': { 'type': "mrkdwn", 'text': message } }
      end

      def block_with_id(message, id)
        { 'block_id': id, 'type': "section", 'text': { 'type': "mrkdwn", 'text': message } }
      end

      def action_block(id)
        { 'block_id': id, 'type': "actions", elements: yield }
      end

      def button(style, text)
        {
          'type': "button",
          'text': {
            'type': "plain_text",
            'emoji': true,
            'text': text.capitalize
          },
          'style': style,
          'value': text.downcase
        }
      end

      def buttons
        buttons = []
        buttons << button("primary", "approve")
        buttons << button("danger", "reject")
        buttons
      end
    end
  end
end
