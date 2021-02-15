module Helm
  class Tidy
    PREFIX = 'apply-'.freeze

    def self.call
      output = ''
      active_uat_namespaces.each do |environment|
        output += if pr_still_exists(environment)
                    "PR still open, retaining #{environment}\n"
                  else
                    "PR deleted - you could run `helm delete #{environment} --dry-run` locally\n"
                  end
      end
      output
    end

    class << self
      private

      def active_uat_namespaces
        uat_releases = JSON.parse(`helm list -o json`, symbolize_names: true)
        uat_releases.map { |helm| helm[:name] } - ["#{PREFIX}master"]
      end

      def open_pull_requests
        application = ApplyApplication.new
        Github::PullRequests.call(application)
      end

      def pull_request_data
        @pull_request_data ||= JSON.parse(open_pull_requests.to_json, symbolize_names: true).map do |pr|
          pr[:head][:ref].gsub(%r{[()\[\]_/\s.]}, '-')
        end
      end

      def pr_still_exists(environment)
        pull_request_data.map { |name| environment.delete_prefix(PREFIX).include?(name) }.any?
      end
    end
  end
end
