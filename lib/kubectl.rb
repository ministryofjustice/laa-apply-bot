class Kubectl
  require 'kubeclient'

  def self.uat_ingresses
    new.uat_ingresses
  end

  def uat_ingresses
    ingresses('laa-apply-for-legalaid-uat')
  end

  private

  # :nocov:
  def ingresses(namespace)
    client.get_ingresses(namespace: namespace, as: :ros).map do |ingress|
      ingress.spec.rules[0].host
    end
  end

  def context
    config = Kubeclient::Config.read(File.expand_path(ENV['KUBE_CONFIG_FILE'] || '~/.kube/config'))
    @context ||= config.context
  end

  def client
    @client ||= Kubeclient::Client.new(
      "#{context.api_endpoint}/apis/networking.k8s.io",
      'v1beta1',
      ssl_options: context.ssl_options, auth_options: context.auth_options
    )
  end
  # :nocov:
end
