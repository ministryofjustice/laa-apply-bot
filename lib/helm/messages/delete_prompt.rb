module Helm
  module Messages
    class DeletePrompt < BaseMessage
      def initialize(service, deletable, deleted = [])
        super()
        @service = service
        @deletable = deletable
        @deleted = deleted
        @merged = @deletable.to_h { |k| [k, 'deletable'] }.merge(@deleted.to_h { |k| [k, 'deleted'] })
      end

      def self.call(service, deletable, deleted = [])
        new(service, deletable, deleted).call
      end

      def call
        result = []
        result << block("No branches or pull requests can be found for the following instances in *#{service}*")
        result << block('Either delete them individually below (you will need to enter a OTP for each button clicked)')
        @merged.each do |context, deleted|
          result << (deleted.eql?('deleted') ? block("~#{context}~") : delete_block_with_button(context))
        end
        # result << block('or, if you are content none are needed, click Delete all contexts')
        # result << action_block('delete_branches') { buttons }
        result
      end

      private

      # :nocov:
      def action_block(id)
        { 'block_id': id, 'type': 'actions', elements: yield }
      end

      def buttons
        buttons = []
        buttons << button('primary', 'Delete all contexts', @deletable.join(';'))
        buttons << button('danger', 'Cancel')
        buttons
      end
      # :nocov:
    end
  end
end
