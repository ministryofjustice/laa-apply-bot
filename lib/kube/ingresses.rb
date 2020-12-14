module Kube
  class Ingresses
    require 'pry-byebug'
    def initialize(namespace)
      @namespace = namespace
    end

    def call
      client = Kube::Client.call
      client.get_ingresses(namespace: @namespace, as: :ros).map do |ingress|
        ingress.spec.rules[0].host
      end
    end

    def self.call(namespace)
      new(namespace).call
    end
  end
end
