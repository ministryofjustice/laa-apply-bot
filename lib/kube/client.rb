module Kube
  class Client
    require "kubeclient"

    def self.call
      new.call
    end

    def call
      Kubeclient::Client.new(
        "#{url}/apis/networking.k8s.io",
        "v1beta1",
        auth_options:,
        ssl_options:
      )
    end

    private

    def auth_options
      { bearer_token: ENV.fetch("KUBE_TOKEN_APPLY") }
    end

    def ssl_options
      { ca_file: ENV.fetch("KUBE_CRT") }
    end

    def url
      ENV.fetch("KUBE_API_URL")
    end
  end
end
