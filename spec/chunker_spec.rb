# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordVector::Chunker do
  describe ".split" do
    it "splits long document text into overlapping chunks" do
      long_text = "Paragraph 1 is about Ruby on Rails.\n\nParagraph 2 is about AI and vector search.\n\nParagraph 3 is about RAG pipelines."
      chunks = described_class.split(long_text, chunk_size: 40, chunk_overlap: 10)

      expect(chunks).not_to be_empty
      expect(chunks.first).to include("Paragraph 1")
    end

    it "handles short text without splitting" do
      short_text = "Hello world"
      chunks = described_class.split(short_text, chunk_size: 100)
      expect(chunks).to eq(["Hello world"])
    end

    it "handles nil or empty text safely" do
      expect(described_class.split(nil)).to eq([])
      expect(described_class.split("   ")).to eq([])
    end
  end
end
