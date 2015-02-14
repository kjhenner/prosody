module Prosody::CMUDictParser
  require 'json'
  def parse_cmudict
    cmudict = File.open('data/cmudict', 'r'){ |f| f.read }
    matches = cmudict.scan(/^([\w\d]+)\s+([\w\d ]+)$/)
    matches.inject({}) do |memo, e|
      memo[e[0]] = memo[e[0]] ? memo[e[0]].concat(parse_phonemes(e[1])) : [parse_phonemes(e[1])]}
      memo
    end
  end
  def parse_phonemes(phoneme_string)
    phonemes = phoneme_string.split.collect do |p|
      m = /(\w+)(\d)?/.match(p)
      {phoneme: m[0], :stress: m[1]}
    end
  end
  def serialize_cmudict(dict)
    File.open("data/cmudict.json", "w") do |f|
      f.write(dict.to_json)
    end
  end
  def load_cmudict_from_json
    File.open("../data/cmudict.json", "r") do |f|
      JSON.parse(File.read(f))
    end
  end
end
