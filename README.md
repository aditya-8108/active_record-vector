<p align="center">
  <h1 align="center">🧠 active_record-vector</h1>
  <p align="center">
    <strong>Native AI vector embeddings, semantic search & RAG for Rails ActiveRecord</strong>
  </p>
  <p align="center">
    <a href="https://rubygems.org/gems/active_record-vector"><img src="https://img.shields.io/gem/v/active_record-vector?color=%23e9573f" alt="Gem Version"></a>
    <a href="https://github.com/aditya-8108/active_record-vector/actions/workflows/ci.yml"><img src="https://github.com/aditya-8108/active_record-vector/actions/workflows/ci.yml/badge.svg" alt="CI Status"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
    <a href="https://rubygems.org/gems/active_record-vector"><img src="https://img.shields.io/gem/dt/active_record-vector?color=green" alt="Downloads"></a>
  </p>
</p>

---

**`active_record-vector`** gives any Rails ActiveRecord model native AI vector embedding generation, semantic similarity search, and RAG (Retrieval-Augmented Generation) document chunking capabilities in 2 lines of code.

Works out-of-the-box with **OpenAI**, **Ollama** (100% free local AI), **Cohere**, **pgvector** (PostgreSQL), and SQLite/MySQL.

---

## ✨ Features

- 🤖 **`has_vector` Macro**: Automatically generates & updates AI vector embeddings on model save callbacks.
- 🔍 **Native ActiveRecord Scopes**: Chain `.semantic_search("query")` and `.nearest_to(vector)` directly with standard Rails queries (`where`, `limit`, `order`).
- 🆓 **Free Local AI via Ollama**: Generate embeddings 100% offline, locally, and free using `nomic-embed-text` or `all-minilm`.
- ⚡ **Multi-Provider Support**: OpenAI (`text-embedding-3-small`), Ollama, Cohere, or custom Procs/Lambdas.
- 📑 **RAG Text Chunker**: Built-in document text splitting utility (`ActiveRecordVector::Chunker`) with token-aware overlap.
- 🗄️ **PostgreSQL `pgvector` Integration**: Migration DSL extensions (`add_vector_column`, `add_vector_index`) supporting `HNSW` and `IVFFlat` indexes with fallback Ruby distance algorithms for SQLite/MySQL.

---

## 📦 Installation

Add to your Rails application's `Gemfile`:

```ruby
gem "active_record-vector"
```

And execute:
```bash
bundle install
```

---

## 🚀 Quick Start

### 1. Define Model Vector Embeddings

Add `has_vector` to your ActiveRecord model:

```ruby
class Article < ApplicationRecord
  has_vector :embedding,
             provider: :openai,                 # :openai, :ollama, :cohere, or custom proc
             model: "text-embedding-3-small",
             from: [:title, :body],              # concatenated automatically
             auto_generate: true                # before_save callback
end
```

### 2. Semantic Similarity Search

Perform vector similarity searches using standard Rails scopes:

```ruby
# Semantic search by query text
Article.semantic_search("Ruby on Rails 8 performance", limit: 5)

# Chain with standard ActiveRecord queries
Article.where(published: true)
       .semantic_search("AI integration", limit: 10)
```

---

## 🦙 Free Local AI Embeddings with Ollama

Generate embeddings 100% offline, privately, and for free using [Ollama](https://ollama.com/):

```ruby
class Article < ApplicationRecord
  has_vector :embedding,
             provider: :ollama,
             model: "nomic-embed-text",  # or "all-minilm"
             host: "http://localhost:11434",
             from: :body
end
```

---

## 📑 RAG Document Text Chunker

Split long documents into overlapping chunks for embedding generation in RAG pipelines:

```ruby
# Split long document text
chunks = ActiveRecordVector::Chunker.split(long_text, chunk_size: 1000, chunk_overlap: 200)

chunks.each do |chunk_text|
  article.chunks.create!(content: chunk_text) # auto-generates vector embedding
end
```

---

## 🛠️ Rails Migration Helpers

```ruby
class AddEmbeddingToArticles < ActiveRecord::Migration[7.2]
  def change
    # Adds pgvector column (or text column fallback on SQLite)
    add_vector_column :articles, :embedding, dimensions: 1536

    # Adds HNSW vector index for high-speed similarity queries
    add_vector_index :articles, :embedding, type: :hnsw, distance: :cosine
  end
end
```

---

## 🛠️ Local Development & Testing

```bash
git clone https://github.com/aditya-8108/active_record-vector.git
cd active_record-vector

bundle config set --local path 'vendor/bundle'
bundle install

# Run test suite
bundle exec rspec
```

---

## 📄 License

Distributed under the [MIT License](LICENSE).
