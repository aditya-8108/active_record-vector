# frozen_string_literal: true

module ActiveRecordVector
  # Document text chunking utility for RAG (Retrieval-Augmented Generation) pipelines.
  # Splits long texts into overlapping chunks for embedding generation.
  class Chunker
    attr_reader :chunk_size, :chunk_overlap, :separators

    DEFAULT_SEPARATORS = ["\n\n", "\n", ". ", " ", ""].freeze

    def initialize(chunk_size: 1000, chunk_overlap: 200, separators: DEFAULT_SEPARATORS)
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
      @separators = separators
    end

    # Convenience class method
    def self.split(text, chunk_size: 1000, chunk_overlap: 200)
      new(chunk_size: chunk_size, chunk_overlap: chunk_overlap).split(text)
    end

    # Split text into array of chunk strings
    def split(text)
      return [] if text.nil? || text.strip.empty?
      return [text.strip] if text.length <= @chunk_size

      splits = split_text(text, @separators)
      merge_splits(splits)
    end

    private

    def split_text(text, separators)
      separator = separators.find { |s| s.empty? || text.include?(s) } || ""
      return text.chars if separator.empty?

      parts = text.split(separator)
      result = []
      parts.each_with_index do |part, idx|
        piece = idx.zero? ? part : "#{separator}#{part}"
        if piece.length > @chunk_size && separators.length > 1
          next_separators = separators[(separators.index(separator) + 1)..]
          result.concat(split_text(piece, next_separators))
        else
          result << piece
        end
      end
      result
    end

    def merge_splits(splits)
      chunks = []
      current_chunk = []
      current_length = 0

      splits.each do |split|
        split_len = split.length

        if current_length + split_len > @chunk_size && current_chunk.any?
          chunk_str = current_chunk.join.strip
          chunks << chunk_str unless chunk_str.empty?

          # Keep overlap
          while current_length > @chunk_overlap && current_chunk.any?
            removed = current_chunk.shift
            current_length -= removed.length
          end
        end

        current_chunk << split
        current_length += split_len
      end

      if current_chunk.any?
        final_str = current_chunk.join.strip
        chunks << final_str unless final_str.empty?
      end

      chunks
    end
  end
end
