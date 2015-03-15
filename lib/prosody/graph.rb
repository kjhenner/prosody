class BigramNode

  attr_accessor :edges
  attr_reader :bigram

  def initialize(type_a, type_b, edges=Hash.new(0))
    raise ArgumentError, "#{type_a} is not a Type" unless type_a.is_a? Type
    raise ArgumentError, "#{type_b} is not a Type" unless type_b.is_a? Type
    @bigram = [type_a, type_b]
    @edges = edges
  end

  def add_edge(node)
    raise ArgumentError, "#{node} is not a BigramNode" unless node.is_a? BigramNode
    @edges[node] += 1
  end

  def to_string
    "#{@bigram[0].string} #{@bigram[1].string}"
  end

end

class Graph

  require 'treat'
  require 'json'
  include Treat::Core::DSL

  attr_accessor :nodes

  def initialize
    @nodes = {}
    @types = {}
  end

  # Loading and serialization
  def remove_linebreaks(string)
    string.gsub(/[\n\r]/, ' ').split.join(' ')
  end

  def load_tokens_from_text(filename)
    p = phrase(remove_linebreaks(open(filename, &:read)))
    p.do(:tokenize)
    p.collect do |t|
      t.value
    end
  end

  def get_bigrams_from_tokens(tokens)
    tokens.collect.with_index do |t, i|
      [t, tokens[i+1] || '']
    end
  end

  def nodes_from_bigrams(bigrams)
    # Iterate through all but the last bigram. The last bigram will be handled
    # as the next_node of the penultimate bigram.
    bigrams[0..-3].each.with_index do |u, i|
      # Ensure the types are in the instance's @types list
      u.each{ |b| @types[b] ||= Type.new(b) }
      # Look up the next node if it already exists, or create it
      next_node = @nodes[bigram_to_s(bigrams[i+2])] ||= BigramNode.new(@types[u[0]], @types[u[1]])
      # Look up the current node if it already exists, or create it
      @nodes[bigram_to_s(u)] ||= BigramNode.new(@types[u[0]], @types[u[1]])
      # Add the next node as an edge of the current node
      @nodes[bigram_to_s(u)].add_edge(next_node)
    end
  end

  def bigram_to_s(bigram)
    "#{bigram[0]}_#{bigram[1]}"
  end

  def random_node
    @nodes[@nodes.keys.sample]
  end

  def next_node(node)
    edge_distribution = []
    e = node.edges
    e.keys.each do |n|
      e[n].times{ edge_distribution << n }
    end
    edge_distribution.sample
  end

end

class Markov

  require 'treat'
  require 'json'
  include Treat::Core::DSL

  def initialize(load_json=nil, load_txt=nil)
    if load_json
      @hash = load_hash_from_json(load_json)
    end
    if load_txt
      @hash = hash_from_text(load_txt)
    end
  end

  def draw_next(line)
    sample = @hash[types_to_s(line[-2], line[-1])].sample
    Type.new(sample[0])
  end

  def draw_first
    sample = @hash.values.sample.sample
    [Type.new(sample[0]), Type.new(sample[1])]
  end

  def generate(n)
    text = []
    bigram = @hash.values.sample[0]
    n.times do
      text.concat([Type.new(bigram[0]), Type.new(bigram[1])])
      bigram = @hash[bigram_to_s(bigram)].sample
    end
    return text
  end

  def types_to_s(a, b)
    bigram_to_s([a.string, b.string])
  end

  def bigram_to_s(bigram)
    "#{bigram[0]}_#{bigram[1]}"
  end
  
  def remove_linebreaks(string)
    string.gsub(/[\n\r]/, ' ')
  end

  def hash_from_text(filename)
    tokens = load_tokens_from_text(filename)
    bigrams = get_bigrams_from_tokens(tokens)
    get_markov_hash_from_bigrams
  end
  
  def load_tokens_from_text(filename)
    p = phrase(remove_linebreaks(open(filename, &:read)))
    p.do(:tokenize)
    p.collect do |t|
      t.value
    end
  end
  
  def get_bigrams_from_tokens(tokens)
    tokens.collect.with_index do |t, i|
      [t, tokens[i+1] || '']
    end
  end
  
  def get_markov_hash_from_bigrams(bigrams)
    hash = {}
    bigrams.each.with_index do |u, i|
      hash[bigram_to_s(u)] ||= []
      hash[bigram_to_s(u)] << bigrams[i+2]
    end
    return hash
  end
  
  def serialize_markov_hash(hash, name)
    File.open("#{name}.json", "w") do |f|
      f.write(hash.to_json)
    end
  end
  
  def load_hash_from_json(name)
    File.open("#{name}.json", "r") do |f|
      JSON.parse(File.read(f))
    end
  end

end
