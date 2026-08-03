# frozen_string_literal: true

module ActiveRecordVector
  # Module included in ActiveRecord models to provide vector capabilities.
  module Model
    extend ActiveSupport::Concern if defined?(ActiveSupport::Concern)

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Macro to enable vector capabilities on a model attribute
      #
      # Example:
      #   has_vector :embedding,
      #              provider: :openai,
      #              model: "text-embedding-3-small",
      #              from: [:title, :body],
      #              auto_generate: true
      def has_vector(attribute = :embedding, options = {})
        @vector_configs ||= {}
        @vector_configs[attribute.to_sym] = {
          provider: options[:provider] || :openai,
          model: options[:model],
          from: Array(options[:from] || :content),
          auto_generate: options.fetch(:auto_generate, true),
          provider_options: options
        }

        # Setup auto-generation callback if supported
        if options.fetch(:auto_generate, true) && respond_to?(:before_save)
          before_save do
            generate_vector_embeddings(attribute.to_sym)
          end
        end

        # Define semantic search scopes if supported
        return unless respond_to?(:scope)

        scope :semantic_search, lambda { |query, target_attribute: attribute, limit: 10, distance: :cosine|
          nearest_to(query, attribute: target_attribute, distance: distance).limit(limit)
        }

        scope :nearest_to, lambda { |query_or_vector, target_attribute: attribute, distance: :cosine|
          cfg = @vector_configs[target_attribute.to_sym] || {}
          query_vector = if query_or_vector.is_a?(Array)
                           query_or_vector
                         else
                           ActiveRecordVector.provider_for(cfg[:provider], cfg[:provider_options]).embed(query_or_vector.to_s)
                         end

          if pgvector_supported?
            pgvector_nearest(query_vector, target_attribute, distance)
          else
            ruby_vector_nearest(query_vector, target_attribute, distance)
          end
        }
      end

      def vector_configs
        @vector_configs ||= {}
      end

      private

      def pgvector_supported?
        respond_to?(:connection) && connection.class.name.include?("PostgreSQL")
      rescue StandardError
        false
      end

      def pgvector_nearest(vector, attribute, distance)
        vector_str = "[#{vector.join(',')}]"
        col_name = connection.quote_column_name(attribute)

        op = case distance.to_sym
             when :cosine then "<=>"
             when :inner_product, :dot then "<#>"
             else "<->" # Euclidean L2
             end

        order("#{col_name} #{op} '#{vector_str}'")
      end

      def ruby_vector_nearest(vector, attribute, distance)
        # Fetch records and sort in memory using ActiveRecordVector::Distance
        records = all.to_a
        sorted = records.sort_by do |record|
          rec_vec = record.public_send(attribute)
          next Float::INFINITY if rec_vec.nil?

          # Parse vector if stored as JSON string
          rec_vec = JSON.parse(rec_vec) if rec_vec.is_a?(String)

          case distance.to_sym
          when :cosine
            -Distance.cosine_similarity(vector, rec_vec) # descending similarity
          when :inner_product, :dot
            -Distance.inner_product(vector, rec_vec)
          else
            Distance.euclidean_distance(vector, rec_vec) # ascending distance
          end
        end

        # Return a scope-like relation using primary keys
        ids = sorted.map(&:id)
        return where(id: nil) if ids.empty?

        begin
          where(id: ids).in_order_of(:id, ids)
        rescue StandardError
          where(id: ids)
        end
      end
    end

    # Instance Methods
    def generate_vector_embeddings(attribute = :embedding)
      cfg = self.class.vector_configs[attribute.to_sym]
      return unless cfg

      source_text = vector_source_text(attribute)
      return if source_text.strip.empty?

      provider = ActiveRecordVector.provider_for(cfg[:provider], cfg[:provider_options])
      vector = provider.embed(source_text)

      public_send("#{attribute}=", vector)
    end

    def vector_source_text(attribute = :embedding)
      cfg = self.class.vector_configs[attribute.to_sym]
      return "" unless cfg

      from_attrs = cfg[:from]
      parts = from_attrs.filter_map do |attr|
        val = respond_to?(attr) ? public_send(attr) : nil
        val.to_s.strip unless val.nil? || val.to_s.strip.empty?
      end

      parts.join("\n\n")
    end
  end
end
