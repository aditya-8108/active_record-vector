# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-08-03

### Added
- Initial release of `active_record-vector`
- `has_vector` macro for ActiveRecord models
- Multi-provider AI embedding support: OpenAI, Ollama (100% free local AI), Cohere, Custom lambdas
- Vector distance metrics: Cosine similarity, Euclidean distance (L2), Inner product
- `semantic_search` and `nearest_to` ActiveRecord scopes
- `ActiveRecordVector::Chunker` for splitting long document text in RAG pipelines
- Migration DSL extensions (`add_vector_column`, `add_vector_index`)
- Support for PostgreSQL `pgvector` index operations (`HNSW`, `IVFFlat`)
