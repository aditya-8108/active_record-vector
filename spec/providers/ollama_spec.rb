# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordVector::Providers::Ollama do
  subject(:provider) { described_class.new(host: "http://localhost:11434", model: "nomic-embed-text") }

  it "parses embedding array from successful Ollama response" do
    stub_response = instance_double(Net::HTTPSuccess, code: "200", is_a?: true)
    allow(stub_response).to receive(:body).and_return({
      embedding: [0.05, 0.15, 0.25]
    }.to_json)

    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(stub_response)

    vector = provider.embed("Local Ollama AI embedding")
    expect(vector).to eq([0.05, 0.15, 0.25])
  end
end
