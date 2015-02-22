module Prosody
  module Rhyme
    require 'treat'
    include Treat::Core::DSL
    def token_to_pronunciations(token, phoneme_dict)
      phoneme_dict[token.upcase] || throw(:not_in_phoneme_dict)
    end
    def last_token(string)
      string.gsub(/[[:punct:]](?=\s|$)/, '').split.pop
    end
    def rhymes?(a, b, phoneme_dict)
      rhyme_combinations(a, b, phoneme_dict)
      .each do |p| 
        p_a = p[0].collect{ |h| h["phoneme"] }
        p_b = p[1].collect{ |h| h["phoneme"] }
        puts p_a
        puts p_b
        return true if p_a[0] != p_b[0] and p_a[1..-1] == p_b[1..-1]
      end
      return false
    end
    def rhyme(pronunciations)
      pronunciations.collect do |c| 
        phoneme_position = c.index(c.max_by{ |s| s["stress"] ? s["stress"].to_i : -1 }) - 1
        until c[phoneme_position+1]["stress"]
          phoneme_position -= 1
        end
        c[phoneme_position..-1].collect
      end
    end
  end
end
