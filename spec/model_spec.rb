# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordVector::Model do
  let(:dummy_class) do
    Class.new do
      include ActiveRecordVector::Model

      attr_accessor :title, :body, :embedding, :id

      has_vector :embedding,
                 provider: :custom,
                 with: ->(_text) { [0.1, 0.2, 0.3] },
                 from: [:title, :body],
                 auto_generate: false

      def initialize(title: "", body: "", embedding: nil, id: 1)
        @title = title
        @body = body
        @embedding = embedding
        @id = id
      end
    end
  end

  it "configures vector_configs via has_vector macro" do
    cfg = dummy_class.vector_configs[:embedding]
    expect(cfg[:provider]).to eq(:custom)
    expect(cfg[:from]).to eq([:title, :body])
  end

  it "concatenates vector_source_text from specified attributes" do
    instance = dummy_class.new(title: "Ruby AI", body: "Vector embeddings in Rails")
    expect(instance.vector_source_text(:embedding)).to eq("Ruby AI\n\nVector embeddings in Rails")
  end

  it "generates vector embedding via configured provider" do
    instance = dummy_class.new(title: "Hello", body: "World")
    instance.generate_vector_embeddings(:embedding)
    expect(instance.embedding).to eq([0.1, 0.2, 0.3])
  end
end
