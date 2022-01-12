module Helm
  require_relative './github_bits'
  class Tidy
    include GithubBits
    attr_accessor :count

    def initialize(match_data, channel)
      parts = match_data['expression'].split
      @context = parts[1] || 'apply'
      @match_data = match_data
      @count = 0
      @channel = channel
      @deletable = []
      active_uat_namespaces.each do |environment|
        update_output_for(environment)
      end
    end

    def self.call(match_data, channel)
      new(match_data, channel).call
    end

    def call
      if @deletable.any?
        SendSlackMessage.new.generic(channel: @channel, as_user: true, blocks: blocks)
        nil
      else
        "There do not seem to be any instances deletable for #{service}"
      end
    end

    private

    def active_uat_namespaces
      uat_releases = JSON.parse(`helm list --kube-context #{@context}-context -o json`, symbolize_names: true)
      uat_releases.map { |helm| helm[:name] } - ["#{PREFIX}main"]
    end

    def update_output_for(environment)
      if still_exists?(environment)
        @count += 1
      else
        @deletable << environment
      end
    end

    def blocks
      ::Helm::Messages::DeletePrompt.call(@context, @deletable)
    end

    def service
      {
        apply: 'Apply',
        cfe: 'CFE',
        hmrc: 'HMRC',
        lfa: 'LFA'
      }[@context.downcase.to_sym]
    end
  end
end
