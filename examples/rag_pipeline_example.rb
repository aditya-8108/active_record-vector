# frozen_string_literal: true

# Example: Complete RAG Pipeline in Rails using active_record-vector
#
# 1. Migration
# class CreateArticlesAndChunks < ActiveRecord::Migration[7.2]
#   def change
#     create_table :articles do |t|
#       t.string :title
#       t.text :content
#       t.timestamps
#     end
#
#     create_table :article_chunks do |t|
#       t.references :article, null: false
#       t.text :content
#       t.vector :embedding, dimensions: 1536
#       t.timestamps
#     end
#     add_index :article_chunks, :embedding, using: :hnsw
#   end
# end

# 2. Article Model with automatic text chunking
class Article < ApplicationRecord
  has_many :chunks, class_name: "ArticleChunk", dependent: :destroy

  after_save :chunk_and_embed_document

  private

  def chunk_and_embed_document
    chunks.destroy_all
    text_chunks = ActiveRecordVector::Chunker.split(content, chunk_size: 1000, chunk_overlap: 200)

    text_chunks.each do |chunk_text|
      chunks.create!(content: chunk_text) # auto-generates vector embedding via ArticleChunk
    end
  end
end

# 3. ArticleChunk Model with active_record-vector
class ArticleChunk < ApplicationRecord
  belongs_to :article

  has_vector :embedding,
             provider: :openai, # or :ollama for free local AI
             model: "text-embedding-3-small",
             from: :content,
             auto_generate: true
end

# 4. RAG Service: Querying relevant context for LLM prompt
class RagService
  def self.answer_question(question)
    # Perform semantic similarity vector search across all document chunks
    relevant_chunks = ArticleChunk.semantic_search(question, limit: 3)
    context_text = relevant_chunks.map(&:content).join("\n\n---\n\n")

    # Pass retrieved context to LLM (OpenAI / Claude / Ollama)
    prompt = <<~PROMPT
      Answer the question using only the context below:

      Context:
      #{context_text}

      Question:
      #{question}
    PROMPT

    # Return LLM completion
    prompt
  end
end
