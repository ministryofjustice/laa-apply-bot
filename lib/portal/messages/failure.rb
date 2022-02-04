module Portal
  module Messages
    class Failure
      def initialize(names)
        @names = names
      end

      def self.call(names)
        new(names).call
      end

      def call
        result = []
        result << block("The following name(s) could not be matched in CCMS")
        result << block("```#{@names.join("\n")}```")
        result << block("You will need to confirm their account names and re-submit")
        result
      end

      private

      def block(message)
        { 'type': "section", 'text': { 'type': "mrkdwn", 'text': message } }
      end
    end
  end
end
