require 'treat'
require 'json'
require_relative './prosody/markov'
require_relative './prosody/cmudict_parser'
require_relative './prosody/type'
require_relative './prosody/rhyme'
require_relative './prosody/markov_generator'
include Treat::Core::DSL
include Prosody::MarkovGenerator
include Prosody::Markov
include Prosody::Rhyme

def generate(hash, n)
  text = ''
  bigram = hash.values.sample[0]
  n.times do
    text << "#{bigram[0]} #{bigram[1]} "
    bigram = hash[bigram_to_s(bigram)].sample
    unless bigram
      bigram = hash.values.sample[0] 
    end
  end
  return text
end

def generate_line(hash, n, rhyming_line=nil, last_bigram=nil)
  line = []
  while line.size < n do
    catch (:not_in_cmu_dict) do
      bigram ||= last_bigram || hash.values.sample[0]
      bigram = hash[bigram_to_s(bigram)].sample || hash.values.sample[0]
      line << bigram
      if line.size == n
        if rhyming_line
          unless is_rhyme?(line, rhyming_line)
            line.pop
          end
        end
      end
    end
  end
  return line
end

def to_phones(a)
  a.gsub(/[[:punct:]]/, '')
   .split
   .collect do |w|
     @cmudict[w.upcase] || throw(:not_in_cmu_dict)
   end
   .flatten
end

def generate_lines(hash, n, line_length, scheme="abbacddc")
  lines = [generate_line(hash, line_length)]
  scheme_hash = {scheme[0] => lines[0]}
  while lines.size < n do
    puts "#{lines[-1].flatten.join(' ')}\r"
    rhyming_line = scheme_hash[rhyme_in_scheme(lines.size, scheme)]
    next_line = generate_line(hash,
                              line_length, 
                              rhyming_line=rhyming_line,
                              last_bigram=lines[-1][-1]
                              )
    scheme_hash[rhyme_in_scheme(lines.size, scheme)] = next_line
    lines << next_line
  end
  return lines
end

def rhyme_in_scheme(i, scheme)
  scheme[i % scheme.size]
end

def merge_hashes(hash_one, hash_two)
  hash_two.keys.each do |k, v|
    if hash_one[k]
      hash_one[k].concat(v)
    else
      hash_one[k] = v
    end
  end
  return hash_one
end

#dict = parse_cmudict
#serialize_cmudict(dict)
#tokens = load_tokens_from_text('mobydick.txt')
#bigrams = get_bigrams_from_tokens(tokens)
#hash = get_markov_hash_from_bigrams(bigrams)
#serialize_markov_hash(hash)
#hash = load_hash_from_json("../data/mobydick_hash")
#@dict = load_cmudict_from_json
#generate_lines(hash, 16, 3).each do |l|
#  puts l.flatten.join(' ')
#end
