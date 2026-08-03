# frozen_string_literal: true

module ActiveRecordVector
  module Providers
    # Abstract base class for embedding providers.
    class Base
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      # Generate embedding vector array for input text string
      def embed(_text)
        raise NotImplementedError, "#{self.class.name}#embed must be implemented"
      end

      # Generate batch embedding vector arrays for array of text strings
      def embed_batch(texts)
        texts.map { |text| embed(text) }
      end
    end
  end
end
