require 'rgl/adjacency'
require 'rgl/edge_properties_map'
require 'pickup'

module Prosody

  class TokenGraph < RGL::DirectedAdjacencyGraph
  
    extend Prosody::TextParser
  
    def initialize
      @edgelist_class = Set
      @vertices_dict = Hash.new
      @edge_properties = Hash.new(0)
      @edge_properties_lambda = lambda { |edge| @edge_properties[edge] }
      @edge_properties_map = RGL::EdgePropertiesMap.new(@edge_properties_lambda, true)
    end
  
    def self.new_from_ngram_pairs(ngram_pairs)
      result = new
      ngram_pairs.each do |ngram_pair|
        result.add_or_weight_edge(ngram_pair[0], ngram_pair[1], 1.0)
      end
      result
    end

    def self.new_from_text_file(file, ngram_size=2)
      ngram_pairs = ngram_pairs_from_file(file, ngram_size)
      self.new_from_ngram_pairs(ngram_pairs)
    end

    def add_or_weight_edge(u, v, weight)
      add_edge(u, v) unless @vertices_dict[[u, v]] 
      @edge_properties[[u, v]] += weight
    end

    def sample_graph_vertices
      @vertices_dict.keys.sample
    end

    def vertex_edges(vertex)
      @vertices_dict[vertex].collect{ |n| [vertex, n] }
    end

    def total_edge_weight(edges)
      edges.inject(0) {|memo,edge| memo += edge_weight(edge)}
    end

    def edge_weight(edge)
      @edge_properties[edge]
    end

    def sample_weighted_vertex_edges(vertex)
      edges = vertex_edges(vertex)
      r = total_edge_weight(edges) * rand
      edges.inject(0) do |memo, edge|
        memo += edge_weight(edge)
        return edge if memo >= r
        memo
      end
      edges[-1]
    end
  
  end

end
