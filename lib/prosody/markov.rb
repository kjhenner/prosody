module Prosody
  
  class MarkovGenerator

    def initialize(graph, dictionary)
      @graph = graph
      @dictionary = dictionary
    end

    def sample_graph_vertices
      @graph.sample_graph_vertices
    end

    def next_vertex(vertex)
      @graph.sample_weighted_vertex_edges(vertex)[1]
    end

    def generate(length)
      text = [sample_graph_vertices]
      while text.size < length do
        text << next_vertex(text[-1])
      end
      text.map{ |bigram| bigram.to_s.split('_').join(' ')}
    end
  end

end
