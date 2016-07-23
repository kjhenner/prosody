module Prosody

  class Dictionary
    
    D = CMUDict.new.dict
    require 'treat'
    include Treat::Core::DSL
    
    IAMBIC = '01'
    
    SEMI_SCUDS = %w{a all am an and are as at be been but by can could dear did do does else for from get got had has have he her hers him his how i if in is it its just least let like may me might most must my no nor not of off on or our own said say says she should since so some than that the their them then there these they this tis to too twas us wants was we were what when where which while who whom why will with would yet you your}
    
    def initialize()
      @
    end

    def meter_with_distance(string, meter)
      begin
        stresses(string)
          .map{ |s| [s, levenshtein_distance(s, meter*(s.size / 2))] }
          .min{ |s| s[1] }
      rescue RuntimeError => e
        puts e
        return ['', 99] 
      end
    end
    
    def token_stress(string)
      return [['0'],['1']] if SEMI_SCUDS.include?(string.downcase)
      D[string.upcase] or raise "No pronunciation entry for '#{string}'"
    end
    
    def stresses(string)
      p = phrase(string)
        .do(:tokenize)
        .map(&:value)
        .reject{ |t| /[[:punct:]]/.match(t) }
        .map{ |t| token_stress(t) }
      first, *rest = *p
      combinations = first
        .product(*rest)
        .map(&:join)
        .map{ |t| t.gsub(/\D/, '') }
        .map{ |t| t.gsub(/2/, '1') }
    end
    
    def levenshtein_distance(s1, s2)
      m = s1.length
      n = s2.length
      return m if n == 0
      return n if m == 0
      d = Array.new(m+1) {Array.new(n+1)}
      (0..m).each{ |i| d[i][0] = i }
      (0..n).each{ |j| d[0][j] = j } 
      (1..n).each do |j|
        (1..m).each do |i|
          d[i][j] = if s1[i-1] == s2[j-1]
                      d[i-1][j-1]
                    else
                      [ d[i-1][j] +1,
                        d[i][j-1]+1,
                        d[i-1][j-1]+1
                      ].min
                    end
        end
      end
      d[m][n]
    end
    
  end
end
