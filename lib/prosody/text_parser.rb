require 'treat'

module Prosody

  module TextParser
  
    include Treat::Core::DSL
  
    def remove_linebreaks(string)
      string.gsub(/[\n\r]/, ' ').split.join(' ')
    end

    def tokens_from_string(string)
      s = remove_linebreaks(string)
      p = phrase(s)
      p.tokenize :stanford
      p.map(&:value)
    end
  
    def ngrams_from_tokens(tokens, ngram_size=2)
      tokens.each_cons(ngram_size).to_a
    end

    def symbol_from_ngram(ngram)
      ngram.join("_").to_sym
    end

    def ngrams_from_string(string, ngram_size=2)
      ngrams_from_tokens(tokens_from_string(string), ngram_size)
    end

    def ngram_pairs(ngrams, ngram_size=2)
      result = []
      (2 * ngram_size).times do |offset|
        slices = (offset .. ngrams.size - 1)
          .step(ngram_size)
          .collect{ |i| symbol_from_ngram(ngrams[i]) }
          .each_slice(ngram_size)
          .to_a
        result += slices
      end
      result 
    end

    def ngram_pairs_from_string(string, ngram_size=2)
      ngrams = ngrams_from_string(string, ngram_size)
      ngram_pairs(ngrams, ngram_size)
    end

    def ngram_pairs_from_file(filename, ngram_size=2)
      ngram_pairs_from_string(File.open(filename, "rb").read, ngram_size)
    end
  
  end
end
