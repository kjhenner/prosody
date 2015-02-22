module Prosody
  module Markov
    require 'treat'
    require 'json'
    include Treat::Core::DSL
    
    def bigram_to_s(bigram)
      "#{bigram[0]}_#{bigram[1]}"
    end
    
    def remove_linebreaks(string)
      string.gsub(/[\n\r]/, ' ')
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
end
