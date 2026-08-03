# frozen_string_literal: true

module ActiveRecordVector
  # Vector distance and similarity calculations.
  module Distance
    class << self
      # Cosine similarity between two float arrays (returns value between -1.0 and 1.0)
      def cosine_similarity(vec_a, vec_b)
        return 0.0 if vec_a.nil? || vec_b.nil? || vec_a.empty? || vec_b.empty?
        return 0.0 unless vec_a.length == vec_b.length

        dot = 0.0
        norm_a = 0.0
        norm_b = 0.0

        vec_a.each_with_index do |val, idx|
          b_val = vec_b[idx]
          dot += val * b_val
          norm_a += val * val
          norm_b += b_val * b_val
        end

        denom = Math.sqrt(norm_a) * Math.sqrt(norm_b)
        return 0.0 if denom.zero?

        dot / denom
      end

      # Euclidean distance (L2 norm) between two float arrays
      def euclidean_distance(vec_a, vec_b)
        return Float::INFINITY if vec_a.nil? || vec_b.nil? || vec_a.empty? || vec_b.empty?
        return Float::INFINITY unless vec_a.length == vec_b.length

        sum = 0.0
        vec_a.each_with_index do |val, idx|
          diff = val - vec_b[idx]
          sum += diff * diff
        end

        Math.sqrt(sum)
      end

      # Dot product (inner product) between two float arrays
      def inner_product(vec_a, vec_b)
        return 0.0 if vec_a.nil? || vec_b.nil? || vec_a.empty? || vec_b.empty?
        return 0.0 unless vec_a.length == vec_b.length

        sum = 0.0
        vec_a.each_with_index do |val, idx|
          sum += val * vec_b[idx]
        end
        sum
      end
    end
  end
end
