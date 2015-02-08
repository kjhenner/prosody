module Prosody::CMUDictParser
  require 'json'
  def parse_cmudict
    cmudict = File.open('data/cmudict', 'r'){ |f| f.read }
    matches = cmudict.scan(/^(?<word>\w+)\(?(?<alternate>\d+)?\)?\s+(?<phones>[\w\d ]+)$/)
    matches = cmudict.scan(/^(?<word>[\w\d]+)\s+(?<phones>[\w\d ]+)$/)
    dict = {}
    matches.each{ |e| dict[e[0]] = dict[e[0]] ? dict[e[0]].concat(e[1].split) : [e[1].split]}
    return dict
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
