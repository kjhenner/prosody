require 'treat'
require 'json'
require 'prosody/markov'
require 'prosody/cmudict_parser'
include Treat::Core::DSL
include Prosody::Markov

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

def is_rhyme?(a, b)
  puts a
  puts b
  ra = rhyme_segment(to_phones(a))
  puts ra
  rb = rhyme_segment(to_phones(b)) 
  puts rb
  ra[:same] == rb[:same] && rb[:different] != ra[:different]
end

def rhyme_segment(a)
  rhyme_segment = {same: []}
  a.reverse!
  a.each.with_index do |p, i|
    rhyme_segment[:same] << p
    if p[-1] == '1' or p[-1] == '2' or p[-1] == '3'
      rhyme_segment[:different] = a[i+1]
      break
    end
  end
  return rhyme_segment
end

def flatten_line(l)
  l.flatten.reject{ |t| t =~ /[[:punct:]]/ }[-1].downcase
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

#tokens = load_tokens_from_text('mobydick.txt')
#bigrams = get_bigrams_from_tokens(tokens)
#hash = get_markov_hash_from_bigrams(bigrams)
#serialize_markov_hash(hash)
hash = load_hash_from_json("../data/mobydick_hash")
@cmudict = load_cmudict_from_json
#puts is_rhyme?('I like to eat wheezes', "I have a big cheeses")
generate_lines(hash, 16, 3).each do |l|
  puts l.flatten.join(' ')
end
