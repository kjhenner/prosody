class CMUDict

  require 'json'

  attr_reader :dict

  def initialize(filepath='data/cmudict')
    @dict = load_from_json(filepath)
    @filepath = filepath
  end

  def parse(filepath)
    cmudict = File.open(filepath, 'r'){ |f| f.read }
    matches = cmudict.scan(/^([\w\d'-]+)(\(\d+\))?\s+([\w\d ]+)$/)
    @dict = matches.inject({}) do |memo, e|
      memo[e[0]] = memo[e[0]] ? memo[e[0]] << e[2] : [e[2]]
      memo
    end
  end

  def serialize(filepath=@filepath)
    File.open("#{filepath}.json", "w") do |f|
      f.write(@dict.to_json)
    end
  end

  def load_from_json(filepath)
    File.open("#{filepath}.json", "r") do |f|
      JSON.parse(File.read(f))
    end
  end

end
