module Helm
  class Tidy
    PREFIX = 'apply-'.freeze

    def self.call
      @output = ''
      @count = 0
      active_uat_namespaces.each do |environment|
        update_output_for(environment)
      end
      @output += "#{@count} #{'branch'.pluralize(@count)} retained"
      @output
    end

    class << self
      private

      def active_uat_namespaces
        uat_releases = JSON.parse(`helm list -o json`, symbolize_names: true)
        uat_releases.map { |helm| helm[:name] } - ["#{PREFIX}master"]
      end

      def open_branches
        application = ApplyApplication.new
        Github::Branches.call(application)
      end

      def branch_data
        @branch_data ||= JSON.parse(open_branches.to_json, symbolize_names: true).map do |branch|
          branch[:name]
        end
      end

      def branch_still_exists(environment)
        branch_data.map { |pr_title| pr_title.include?(environment.delete_prefix(PREFIX)) }.any?
      end

      def update_output_for(environment)
        if branch_still_exists(environment)
          @count += 1
        else
          @output += ":nope: #{environment} - branch deleted - you can run the following locally  - " \
                    "`helm delete #{environment} --dry-run`\n"
        end
      end
    end
  end
end
