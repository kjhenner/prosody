require File.expand_path '../../spec_helper.rb', __FILE__

describe Graph do
  before(:each) do
    @g = Graph.new
  end
  describe 'initialize' do
    it 'initializes with empty hashes for @nodes and @types' do
      expect(@g.nodes.is_a? Hash).to eq(true)
      expect(@g.nodes.size).to eq(0)
      expect(@g.instance_variable_get(:@types).is_a? Hash).to eq(true)
      expect(@g.instance_variable_get(:@types).size).to eq(0)
    end
  end
  describe 'remove_linebreaks' do
    it 'removes linebreaks from a string' do
      str = "I like \n to \r eat \n    food"
      expect(@g.remove_linebreaks(str)).to eq("I like to eat food")
    end
  end
  describe 'load_tokens_from_text' do
    it 'loads a text file and converts it into an array of tokens' do
      tokens = @g.load_tokens_from_text("data/dicktest.txt")
      expect(tokens.size).to eq(651)
      expect(tokens).to include('content')
    end
  end
  describe 'bigram_to_s' do
    it 'converts a bigram to a string representation' do
      expect(@g.bigram_to_s(['the', 'dog'])).to eq('the_dog')
    end
  end
  describe 'get_bigrams_from_tokens' do
    it 'converts a list of tokens into a list of bigrams (token pairs)' do
      tokens = @g.load_tokens_from_text("data/dicktest.txt")
      bigrams = @g.get_bigrams_from_tokens(tokens)
      expect(bigrams.size).to eq(651)
      expect(bigrams).to include(['be', 'content'])
    end
  end
  describe 'nodes_from_bigrams' do
    before(:each) do
      tokens = @g.load_tokens_from_text("data/dicktest.txt")
      bigrams = @g.get_bigrams_from_tokens(tokens)
      @g.nodes_from_bigrams(bigrams)
    end
    it 'converts an array of bigrams into a hash of BigramNodes' do
      expect(@g.nodes.size).to eq(580)
      expect(@g.nodes.keys).to include("'s_shoulder-blades")
    end
    it 'appropriately adds edges' do
      # This test isn't great. I should more carefully determine some
      # cases and test them.
      keys = @g.nodes.keys
      expect(@g.nodes[keys[0]].edges[@g.nodes[keys[2]]]).to eq(0)
    end
  end
  describe 'random_node' do
    before(:each) do
      tokens = @g.load_tokens_from_text("data/dicktest.txt")
      bigrams = @g.get_bigrams_from_tokens(tokens)
      @g.nodes_from_bigrams(bigrams)
    end
    it 'selects a random node' do
      expect(@g.random_node.is_a? BigramNode).to eq(true)
    end
  end
  describe 'next_node' do
    before(:each) do
      tokens = @g.load_tokens_from_text("data/dicktest.txt")
      bigrams = @g.get_bigrams_from_tokens(tokens)
      @g.nodes_from_bigrams(bigrams)
    end
    it 'selects a connected node based on edge weights' do
      first = @g.random_node
      n = @g.next_node(first)
      puts first.to_string
      puts n.to_string
    end
  end
end


describe BigramNode do
  before(:each) do
    type_a = Type.new('test')
    type_b = Type.new('breast')
    type_c = Type.new('crest')
    @bn = BigramNode.new(type_a, type_b)
    @bn2 = BigramNode.new(type_b, type_c)
  end
  describe 'the edge variable' do
    it 'returns zero for an un-added edge' do
      expect(@bn.edges['foo']).to eq(0)
    end
  end
  describe 'inintialize' do
    it 'sets the @bigram variable' do
      @bn.bigram.each do |b|
        expect(b.is_a? Type).to eq(true)
      end
    end
  end
  describe 'add_edge' do
    it 'adds an edge to the node' do
      @bn.add_edge(@bn2)
      expect(@bn.edges).to include(@bn2)
      expect(@bn.edges[@bn2]).to eq(1)
    end
  end
end

