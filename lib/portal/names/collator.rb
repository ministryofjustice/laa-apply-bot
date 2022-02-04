module Portal
  module Names
    class Collator
      # statuses - created, good, bad, mixed
      attr :status, :matched, :unmatched

      def initialize(names)
        # this should be passed the raw match data
        @names = names.split(",").map(&:strip).map(&:upcase)
        @status = :created
        process
      end

      def matched_names
        @matched_names ||= @matched.map(&:portal_username)
      end

      def unmatched_names
        @unmatched_names ||= @unmatched.map(&:portal_username)
      end

    private

      def process
        name_list.each do |name|
          if Portal::NameValidator.call(name)
            @matched = Array(@matched).push(name)
            update_status(:good)
          else
            @unmatched = Array(@unmatched).push(name)
            update_status(:bad)
          end
        end
      end

      def update_status(update)
        return if @status.eql?(:mixed)
        return if @status.eql?(update)

        @status = update if @status.eql?(:created)
        @status = :mixed unless @status.eql?(update)
      end

      def name_list
        @name_list ||= @names.map { |user| Portal::Name.new(user) }
      end
    end
  end
end
