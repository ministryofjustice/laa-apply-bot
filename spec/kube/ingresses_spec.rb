require "rspec"

describe Kube::Ingresses do
  subject(:kube_ingresses) { described_class.new(namespace) }
  before do
    stub_request(:get, %r{\Ahttp://api.fake.k8s.host/.*\z})
      .to_return(status: 200, body: ingress_response, headers: {})
    stub_request(:get, %r{\Ahttp://api.fake.k8s.host/.*/ingresses\z})
      .to_return(status: 200, body: resource_response, headers: {})
  end

  let(:namespace) { "test" }
  let(:ingress_response) do
    <<~JSON.as_json
      {"kind": "APIResourceList",
       "apiVersion": "v1",
       "groupVersion": "networking.k8s.io/v1beta1",
       "resources":
        [{"name": "ingresses",
          "singularName": "",
          "namespaced": true,
          "kind": "Ingress",
          "verbs":
           ["create",
            "delete",
            "deletecollection",
            "get",
            "list",
            "patch",
            "update",
            "watch"],
          "shortNames": ["ing"],
          "storageVersionHash": "ZOAfGflaKd0="},
         {"name": "ingresses/status",
          "singularName": "",
          "namespaced": true,
          "kind": "Ingress",
          "verbs": ["get", "patch", "update"]}]}
    JSON
  end
  let(:resource_response) do
    <<~JSON
      {
        "items": [
          {
            "spec": {
              "rules": [
                {
                  "host": "ap-1234.test.service.uk"
                }
              ]
            }
          }
        ]
      }
    JSON
  end

  it { is_expected.to be_a Kube::Ingresses }

  describe "#call" do
    subject(:call) { kube_ingresses.call }

    it { is_expected.to eq ["ap-1234.test.service.uk"] }
  end

  describe ".call" do
    subject(:call) { described_class.call(namespace) }

    it { is_expected.to be_an Array }
  end
end
