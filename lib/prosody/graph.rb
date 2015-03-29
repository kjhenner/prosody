class BigramNode

  attr_accessor :edges
  attr_reader :bigram

  def initialize(type_a, type_b)
    raise ArgumentError, "#{type_a} is not a Type" unless type_a.is_a? Type
    raise ArgumentError, "#{type_b} is not a Type" unless type_b.is_a? Type
    @bigram = [type_a, type_b]
    @edges = []
  end

  def serialize
    {
     'bigram' => @bigram.collect(&:string),
     'edges' => @edges
    }
  end

  def add_edge(node)
    raise ArgumentError, "#{node} is not a BigramNode" unless node.is_a? BigramNode
    @edges << node.to_string
  end

  def to_string
    "#{@bigram[0].string} #{@bigram[1].string}"
  end

  def sample_neighbors(exclude=nil, rhyme=nil)
    e = @edges
    return nil unless e
    if exclude
      e = e.reject{ |edge| exclude.include?(edge) }
      return nil unless e
    end
    if rhyme
      e = e.select{ |edge| edge.rhymes_with?(rhyme) }
      return nil unless e
    end
    e.sample
  end

  def can_end_sentence?
    return @can_end_sentence if @can_end_sentence
    @can_end_sentence = @bigram[1].stop?
  end

end

class Graph

  require 'treat'
  require 'json'
  include Treat::Core::DSL

  attr_accessor :nodes

  def initialize(json=nil, text=nil)
    # { bigram_string => bigram node }
    @nodes = {}
    @types = {}
    if json
      load_json(json)
    end
  end

  def inspect
    "A graph"
  end

  # Loading and serialization
  
  def serialize(name)
    raise RuntimeError, "No nodes to serialize" if @nodes.empty?
    raise RuntimeError, "No types to serialize" if @types.empty?
    h = {
          'nodes' => @nodes.values.collect(&:serialize),
          'types' => @types.keys
        }
    File.open("data/#{name}.json", "w") do |f|
      f.write(h.to_json)
    end
  end

  def load_json(name)
    h = File.open("data/#{name}.json", "r") do |f|
      JSON.parse(File.read(f))
    end
    h['types'].each do |t|
      @types[t] ||= Type.new(t) 
    end
    h['nodes'].each do |n|
      node = BigramNode.new(@types[n['bigram'][0]], @types[n['bigram'][1]])
      @nodes[node.to_string] ||= node
    end
    h['nodes'].each do |n|
      node = @nodes[bigram_to_s(n['bigram'])]
      n['edges'].each do |e|
        node.add_edge(@nodes[e]) if @nodes[e]
      end
    end
  end

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
      bigrams[i+2].each{ |b| @types[b] ||= Type.new(b)}
      # Look up the next node if it already exists, or create it
      next_node = @nodes[bigram_to_s(bigrams[i+2])] || BigramNode.new(@types[bigrams[i+2][0]], @types[bigrams[i+2][1]])
      # Look up the current node if it already exists, or create it
      @nodes[bigram_to_s(u)] ||= BigramNode.new(@types[u[0]], @types[u[1]])
      # Add the next node as an edge of the current node
      @nodes[bigram_to_s(u)].add_edge(next_node)
    end
  end

  def sample_neighbors(node, exclude=nil, rhyme=nil, final=false)
    return nil unless node
    e = node.edges
    return nil unless e
    if exclude
      e = e.reject do |edge| 
        exclude.include?(edge)
      end
      return nil if e.empty?
    end
    if final
      e = e.select do |edge|
        edge_final = @nodes[edge].edges.select{ |ne| @nodes[ne].bigram[0].stop? }
        is_final = @nodes[edge].bigram[1].stop? || edge_final 
      end
      return nil if e.empty?
    end
    if rhyme
      e = e.select do |edge|
        return nil unless @nodes[edge]
        bigram = @nodes[edge].bigram
        type = /^[[:punct:]]$/.match(bigram[1].string) ? bigram[0] : bigram[1]
        type.rhymes_with?(rhyme)
      end
      return nil if e.empty?
    end
    e[rand(e.size)]
  end

  def bigram_to_s(bigram)
    "#{bigram[0]} #{bigram[1]}"
  end

  def random_node
    @nodes[@nodes.keys.sample]
  end

  def random_node_key
    @nodes.keys.sample
  end

  def find_poem(line_length=5, scheme='abba')
    rhymes = {}
    line_count = 0
    starts = @nodes.keys.dup
    path = [[starts.delete_at(rand(starts.size)), [], '']]
    while line_count < scheme.length
      unless path[0]
        if starts.empty?
          puts "no matching lines found!"
          break
        end
        path[0] = [starts.delete_at(rand(starts.size)), [], '']
      end
      current_node = path[-1][0]
      if path.size % line_length == 0
        if rhymes[scheme[line_count]]
          rhyme = rhymes[scheme[line_count]]
          next_node = sample_neighbors(@nodes[current_node], exclude=path[-1][1], rhyme=rhyme)
        else
          next_node = sample_neighbors(@nodes[current_node], exclude=path[-1][1])
          rhymes[scheme[line_count]] = @nodes[next_node].bigram[1]
        end
      else
        next_node = sample_neighbors(@nodes[current_node], exclude=path[-1][1])
      end
      if next_node
        path[-1][1] << next_node
        if path.size % line_length == 0
          line_count += 1
          path << [next_node, [], "\n"]
        else
          path << [next_node, [], '']
        end
      else
        path.pop
      end
    end
    return path.collect{ |p| p[0] + p[2] }.join(' ')
  end

end

class Poem

  def initialize(graph, line_length, scheme)
    @line_length = line_length
    @scheme = scheme
    @rhymes = {}
    @line_count = 0
    @graph = graph
    @starts = get_starts
    @path = [init_path]
  end

  def to_s
    "#{@line_length}, #{@scheme}"
  end
  
  def init_path
    {
      bigram: first_bigram, 
      excluded_bigrams: [], 
      line_end: ''
    }
  end

  def first_bigram
    @starts.delete_at(rand(@starts.size))
  end

  def get_starts
    # Find and array of sentence-initial bigrams
    @graph.nodes.keys.select{ |k| @graph.nodes[k].can_end_sentence? }
      .collect{ |n| @graph.nodes[n].edges }
      .flatten
      .uniq
  end

  def print_path
    @path.collect{ |p| p[:bigram] + p[:line_end] }.join(' ')
  end

  def get_rhyme
    path_index = (@scheme.index(@scheme[@line_count]) + 1) * @line_length - 1
    bigram = @graph.nodes[@path[path_index][:bigram]].bigram rescue nil
    return nil unless bigram
    type = /^[[:punct:]]$/.match(bigram[1].string) ? bigram[0] : bigram[1]
  end

  def generate
    while @line_count < @scheme.size # while there are fewer lines than specified
      if @path.empty?
        # The first bigram led to a dead-end
        unless @starts.empty?
          # There were no valid poems found with the first bigram
          # Take a new bigram from the @starts array and try again
          @path = [init_path]
        else
          # There were no more starts in the @starts array to try
          puts "Couldn't find a valid poem!"
          break
        end
      end
      bigram = @graph.nodes[@path[-1][:bigram]]
      excluded_bigrams = @path[-1][:excluded_bigrams]
      final = @line_count == @scheme.size() - 1 ? true : false
      #final = nil
      if (@path.size + 1) % @line_length == 0
        # If the next bigram will complete a line 
        #rhyme = @rhymes[@scheme[@line_count]]
        rhyme = get_rhyme
        next_node = @graph.sample_neighbors(bigram, exclude=excluded_bigrams, rhyme=rhyme, final=final)
        next_path_element = {
          bigram: next_node,
          excluded_bigrams: [],
          line_end: "\n"
        }
      else
        # If the next bigram won't complete a line
        next_node = @graph.sample_neighbors(bigram, exclude=excluded_bigrams, rhyme=nil, final=nil)
        next_path_element = {
          bigram: next_node,
          excluded_bigrams: [],
          line_end: ''
        }
      end
      if next_node
        # Mark the next node as already tried for the
        # current node. If the path encounters a dead end
        # following this node, it won't be picked again next
        # time.
        if (@path.size + 1) % @line_length == 0
          @rhymes[@scheme[@line_count]] ||= @graph.nodes[next_node].bigram[1]
        end
        @path[-1][:excluded_bigrams] << next_node
        @path << next_path_element
      else
        if (@path.size + 1) % @line_length == 0
          @rhymes[@scheme[@line_count]] == nil
        end
        @path.pop
      end
      @line_count = @path.collect{ |p| p[:line_end] }
                         .reject{ |f| f == '' }
                         .size
      puts print_path
    end
    return print_path
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
