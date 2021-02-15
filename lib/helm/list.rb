module Helm
  class List
    def self.call
      releases = JSON.parse(`helm list -o json`, symbolize_names: true)
      values = releases.pluck(:name, :status, :updated)
      "#{header}\n#{values.map { |row| parse_row(row) }.join("\n")}"
    end

    class <<self
      private

      def header
        "#{parse_name('Name')}#{parse_state('Status')}Date"
      end

      def parse_row(data)
        "#{parse_name(data[0])}#{parse_state(data[1])}#{parse_date(data[2]).strftime('%Y-%m-%d')}"
      end

      def parse_name(name)
        name.ljust(40, ' ')
      end

      def parse_state(state)
        state.ljust(15, ' ')
      end

      def parse_date(date)
        Date.parse(date)
      end
    end
  end
end
