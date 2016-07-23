require 'rgl/traversal'
module Prosody
  
  class PoemVisitor < RGL::DFSVisitor

    def initialize(graph, contract)
      @contract = contract
      super(graph)
    end

#    def basic_forward
#      u = next_vertex
#      handle_examine_vertex(u)
#
#      graph.each_adjacent(u) do |v|
#        if follow_edge?(u, v)
#          handle_tree_edge(u, v)
#          color_map[v] = :GRAY
#          @waiting.push(v)
#        else
#          if color_map[v] == :GRAY
#            handle_back_edge(u, v)
#          else
#            handle_forward_edge(u, v)
#          end
#        end
#      end
#      color_map[u] = :BLACK
#      handle_finish_vertex(u)
#    end
#
#    def sort_adjacent_by_contract_fit(u)
#      graph.each_adjacent(u).sort_by do |node|
#        evaluate_contract_fit(node)
#      end
#    end
#
#    def evaluate_contract_fit(node)
#      
#    end
#
  end

end
