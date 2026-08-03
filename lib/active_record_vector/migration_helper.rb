# frozen_string_literal: true

module ActiveRecordVector
  # Helper module providing migration DSL extensions for adding vector columns and indexes.
  module MigrationHelper
    # Add vector column to a table (supports PostgreSQL pgvector and JSON fallback)
    def add_vector_column(table_name, column_name, dimensions: 1536, **options)
      if postgresql_adapter?
        execute "CREATE EXTENSION IF NOT EXISTS vector;"
        execute "ALTER TABLE #{table_name} ADD COLUMN #{column_name} vector(#{dimensions});"
      else
        add_column table_name, column_name, :text, **options
      end
    end

    # Add HNSW or IVFFlat vector index to a table
    def add_vector_index(table_name, column_name, type: :hnsw, distance: :cosine)
      return unless postgresql_adapter?

      ops_class = case distance.to_sym
                  when :cosine then "vector_cosine_ops"
                  when :inner_product, :dot then "vector_ip_ops"
                  else "vector_l2_ops"
                  end

      index_type = type.to_s.upcase
      index_name = "index_#{table_name}_on_#{column_name}_#{type}"

      execute "CREATE INDEX IF NOT EXISTS #{index_name} ON #{table_name} USING #{index_type} (#{column_name} #{ops_class});"
    end

    private

    def postgresql_adapter?
      respond_to?(:adapter_name) && adapter_name.to_s.match?(/postgres/i)
    rescue StandardError
      false
    end
  end
end
