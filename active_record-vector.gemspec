# frozen_string_literal: true

require_relative "lib/active_record_vector/version"

Gem::Specification.new do |spec|
  spec.name          = "active_record-vector"
  spec.version       = ActiveRecordVector::VERSION
  spec.authors       = ["Aditya"]
  spec.summary       = "Native vector embeddings, semantic search & RAG for Rails ActiveRecord"
  spec.description   = "An elegant, lightweight Ruby gem bringing native AI vector embeddings, " \
                       "semantic similarity search, and RAG document chunking to Rails ActiveRecord models. " \
                       "Supports OpenAI, Ollama (free local AI), Cohere, and pgvector."
  spec.homepage      = "https://github.com/aditya-8108/active_record-vector"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  # Core dependencies
  spec.add_dependency "activesupport", ">= 6.0", "< 9.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }
end
