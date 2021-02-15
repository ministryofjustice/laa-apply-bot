module Helm
  class List
    def self.call
      releases = JSON.parse(`helm list -o json`)
      releases.map { |release| release['name'] }.join("\n")
    end
  end
end
