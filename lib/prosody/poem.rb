class Poem

  def initialize(graph, line_length, scheme)
    @line_length = line_length
    @scheme = scheme
    @rhymes = {}
    @line_count = 0
    @graph = graph
    @starts = get_starts
    @path = [init_path]
    @meter = '01'
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

  def generate_line(previous_bigram, length, rhyme, meter, starts_sentence, ends_sentence)
    line = ''
    while meter_with_distance(line)[0].size < length
      if line.size = 0
        line = first_bigram
      end
      next_node = @graph.sample_neighbors(bigram, exclude=excluded_bigrams, rhyme=rhyme, final=final, path=print_path, meter=@meter)
    end
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
        next_node = @graph.sample_neighbors(bigram, exclude=excluded_bigrams, rhyme=rhyme, final=final, path=print_path, meter=@meter)
        next_path_element = {
          bigram: next_node,
          excluded_bigrams: [],
          line_end: "\n"
        }
      else
        # If the next bigram won't complete a line
        next_node = @graph.sample_neighbors(bigram, exclude=excluded_bigrams, rhyme=nil, final=nil, path=print_path, meter=@meter)
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
