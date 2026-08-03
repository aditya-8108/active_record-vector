# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordVector::Distance do
  let(:vec_a) { [1.0, 2.0, 3.0] }
  let(:vec_b) { [1.0, 2.0, 3.0] }
  let(:vec_c) { [-1.0, -2.0, -3.0] }
  let(:vec_d) { [4.0, 5.0, 6.0] }

  describe ".cosine_similarity" do
    it "calculates 1.0 for identical vectors" do
      expect(described_class.cosine_similarity(vec_a, vec_b)).to be_within(0.0001).of(1.0)
    end

    it "calculates -1.0 for opposite vectors" do
      expect(described_class.cosine_similarity(vec_a, vec_c)).to be_within(0.0001).of(-1.0)
    end

    it "returns 0.0 for empty or nil vectors" do
      expect(described_class.cosine_similarity(nil, vec_a)).to eq(0.0)
      expect(described_class.cosine_similarity([], vec_a)).to eq(0.0)
    end
  end

  describe ".euclidean_distance" do
    it "calculates 0.0 for identical vectors" do
      expect(described_class.euclidean_distance(vec_a, vec_b)).to eq(0.0)
    end

    it "calculates correct L2 distance" do
      dist = described_class.euclidean_distance(vec_a, vec_d)
      expect(dist).to be_within(0.001).of(5.196) # sqrt((3)^2 + (3)^2 + (3)^2) = sqrt(27) = 5.196
    end
  end

  describe ".inner_product" do
    it "calculates dot product" do
      expect(described_class.inner_product(vec_a, vec_d)).to eq(32.0) # 1*4 + 2*5 + 3*6 = 32
    end
  end
end
