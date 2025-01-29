require "./lib/btree"

describe BTree do
  let(:root_only_tree) { described_class.new(factor: 3) }
  let(:two_level_tree) do
    described_class.new(factor: 2).tap do |tree|
      [11, 30, 35, 120, 25].each { |el| tree.push(el) }
    end
  end
  let(:big_tree) do
    described_class.new(factor: 2).tap do |tree|
      1.upto(1000).each { |el| tree.push(el) if el % 3 == 1 }
    end
  end

  let(:factor) { 3 }

  describe "#initialize" do
    it "is initialized with root element" do
      expect(root_only_tree.to_a).to eq([[[]]])
    end
  end

  describe "#push" do
    it "pushes elements to root node" do
      els = [11, 30, 35, 120]
      els.each { |el| root_only_tree.push(el) }

      expect(root_only_tree.to_a).to eq([[(els).sort]])
    end

    it "correctly splits nodes to keep tree balanced" do
      expect(two_level_tree.to_a).to eq([[[30]], [[11, 25], [35, 120]]])
    end

    it "doesn't push existing elements and returns false on such push" do
      expect(two_level_tree.push(11)).to be false
      expect { two_level_tree.push(11) }.not_to change(two_level_tree, :to_a)
    end
  end

  describe "#find" do
    it "finds element and returns it if it exists" do
      expect(big_tree.find(100)).to eq(100)
    end

    it "returns nil if no such value in tree" do
      expect(big_tree.find(101)).to be nil
    end
  end

  describe "#upper_bound" do
    it "returns value if it's present in tree" do
      expect(big_tree.upper_bound(100)).to eq(100)
    end

    it "returns closest bigger element present in tree if there're some bigger" do
      expect(big_tree.upper_bound(500)).to eq(502)
      expect(big_tree.upper_bound(-10_000)).to eq(1)
    end

    it "returns nil if there're no bigger elements in tree" do
      expect(big_tree.upper_bound(1001)).to be nil
    end
  end

  describe "#lower_bound" do
    it "returns value if it's present in tree" do
      expect(big_tree.lower_bound(100)).to eq(100)
    end

    it "returns closest smaller element present in tree if there're some bigger" do
      expect(big_tree.lower_bound(504)).to eq(502)
      expect(big_tree.lower_bound(10_000)).to eq(1000)
    end

    it "returns nil if there're no smaller elements in tree" do
      expect(big_tree.lower_bound(0)).to be nil
    end
  end

  describe "#drop_lower_than" do
    it "removes all subtrees if all values are smaller than given one" do
      big_tree.drop_lower_than(2000)
      big_tree.push(100)
      expect(big_tree.to_a).to eq([[[100]]])
    end

    it "removes values that are smaller than given" do
      big_tree.drop_lower_than(900)
      expect(big_tree.to_a).to eq([
        [[910]],
        [[904], [934, 958]],
        [[901], [907], [922], [946], [970, 982]],
        [[916], [928], [940], [952], [964], [976], [988, 994]],
        [[913], [919], [925], [931], [937], [943], [949], [955], [961], [967], [973], [979], [985], [991], [997, 1000]]
      ])
    end
  end
end
