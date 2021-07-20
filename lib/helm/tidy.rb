module Helm
  class Tidy
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
      include GithubBits

      private

      def active_uat_namespaces
        uat_releases = JSON.parse(`helm list -o json`, symbolize_names: true)
        uat_releases.map { |helm| helm[:name] } - ["#{PREFIX}master"]
      end

      def update_output_for(environment)
        if still_exists?(environment)
          @count += 1
        else
          @output += ":nope: #{environment} - branch deleted - you can run the following locally  - " \
                     "`helm delete #{environment} --dry-run`\n"
        end
      end
    end
  end
end
