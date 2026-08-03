# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordVector::Providers::Openai do
  subject(:provider) { described_class.new(api_key: "dummy_key", model: "text-embedding-3-small") }

  it "raises error if API key is missing" do
    provider_no_key = described_class.new(api_key: nil)
    allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return(nil)
    expect { provider_no_key.embed("test") }.to raise_error(ActiveRecordVector::Error, /API key missing/)
  end

  it "parses embedding array from successful API response" do
    stub_response = instance_double(Net::HTTPSuccess, code: "200", is_a?: true)
    allow(stub_response).to receive(:body).and_return({
      data: [{ embedding: [0.1, 0.2, 0.3] }]
    }.to_json)

    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(stub_response)

    vector = provider.embed("Ruby on Rails AI")
    expect(vector).to eq([0.1, 0.2, 0.3])
  end
end
