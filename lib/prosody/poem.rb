class Poem

  def initialize(markov, length)
    @markov = markov
    @length = length
    @rhyme_scheme = 'abba'
    @text
  end

  def generate_line(rhyme=nil)
    line = @markov.draw_first
    while line.size <= @length 
      print print_line(line) + "\r"
      STDOUT.flush
      if line.size == @length and rhyme
        r = @markov.draw_next(line)
        tries = 0
        until r.rhymes_with?(rhyme) or tries > 1000
          r = @markov.draw_next(line)
          tries += 1
        end
        if r.rhymes_with?(rhyme)
          line << r
        else
          line.pop(2)
        end
      else
        line << @markov.draw_next(line)
      end
    end
    return line
  end

  def print_line(line)
    line.collect{ |t| t.string }.join(" ")
  end

end
