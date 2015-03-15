require File.expand_path '../../spec_helper.rb', __FILE__

describe Poem do
  D = CMUDict.new
  m = Markov.new(load_json='data/mobydick_hash')
  p = Poem.new(m, 10)
  describe 'generate_line' do
    it ' generates a line' do
      l1 = p.generate_line
      l2 = p.generate_line(l1[-1])
      puts [l1, l2].collect{ |l| p.print_line(l) }
    end
  end
end
