module Helm
  class List
    def self.call(context = "apply")
      context = "--kube-context #{context}-context"
      raw_output = helm_list_as_json(context)
      releases = parse_releases(raw_output)
      values = releases.pluck(:name, :status, :updated)
<<<<<<< HEAD
      result = "#{header}\n#{values.map { |row| parse_row(row) }.join("\n")}"
=======
      SlackRubyBot::Client.logger.warn("Values populated")
      result = "#{header}\n#{values.map { |row| parse_row(row) }.join("\n")}"
      SlackRubyBot::Client.logger.warn("Result populated")
>>>>>>> d99ad0e (re-run rubocop autocorrect)
      "```#{result}```"
    end

    class << self
      include GithubBits

    private

      def helm_list_as_json(context)
<<<<<<< HEAD
        `helm list #{context} -o json`
      end

      def parse_releases(raw_output)
        JSON.parse(raw_output, symbolize_names: true)
=======
        raw_data = `helm list #{context} -o json`
        SlackRubyBot::Client.logger.warn("raw_output populated")
        raw_data
      end

      def parse_releases(raw_output)
        result = JSON.parse(raw_output, symbolize_names: true)
        SlackRubyBot::Client.logger.warn("Releases populated")
        result
>>>>>>> d99ad0e (re-run rubocop autocorrect)
      end

      def header
        # "#{parse_name('Name')}#{parse_state('Status')}#{'Date'.ljust(11)}#{parse_data('Branch')}#{parse_data('PR')}"
        [
          parse_name("Name"),
          parse_state("Status"),
          "Date".ljust(11),
          "PR".ljust(3, " "),
          parse_data("Branch"),
        ].join
      end

      def parse_row(data)
        # "#{parse_name(data[0])}#{parse_state(data[1])}#{parse_date(data[2]).strftime('%Y-%m-%d')}"
        [
          parse_name(data[0]),
          parse_state(data[1]),
          parse_date(data[2]).strftime("%Y-%m-%d").ljust(11),
          (pr_still_exists(data[0]) ? "✔" : "").ljust(3, " "),
          parse_data((branch_still_exists(data[0]) ? "✔" : "")),
        ].join
      end

      def parse_name(name)
        name.ljust(40, " ")
      end

      def parse_state(state)
        state.ljust(15, " ")
      end

      def parse_data(value)
        value.ljust(7, " ")
      end

      def parse_date(date)
        Date.parse(date)
      end
    end
  end
end
