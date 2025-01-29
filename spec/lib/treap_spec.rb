require "./lib/treap"

describe Treap do
  let(:root_only_tree) { described_class.new(3, 10) }

  describe "#initialize" do
    it "initializes tree with root element" do
      expect(root_only_tree.to_a).to eq([[3]])
      expect(root_only_tree.to_a(priority: true)).to eq([[10]])
    end
  end

  describe "#push" do
    it "builds binary search tree when pushing values with priorities forming a heap" do
      [[6, 2], [5, 3], [11, 12], [21, 15]].each do |value, priority|
        root_only_tree.push(value, priority)
      end

      expect(root_only_tree.to_a).to eq([
        [6],
        [5, 11],
        [3, 21]
      ])

      expect(root_only_tree.to_a(priority: true)).to eq([
        [2],
        [3, 12],
        [10, 15]
      ])
    end
  end

  describe "#closest_with_min_priority" do
    let(:search_tree) do
      described_class.new(7, 14).tap do |tree|
        [[11,6],[3,1],[9,4],[14,14],[17,11],[22,13],[6,25],[12,22],[21,9]].each do |value, priority|
          tree.push(value, priority)
        end
      end
    end

    let(:queries) do
      [[21,17],[4,6],[17,25],[15,18],[17,16],[18,16],[8,17],[6,7],[9,22],[17,18], [11, 300]]
    end

    let(:expected_result) do
      [12,6,6,12,12,12,6,6,6,12, nil]
    end
      
    it "retrieves closest by abs diff element with at least given min priority" do
      queries.each_with_index do |(value, priority), index|
        expect(search_tree.closest_with_min_priority(value, priority)).to eq(expected_result[index])
      end
    end
  end
end
