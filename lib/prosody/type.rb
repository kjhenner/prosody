class Type

  @@r = /^(?<similarity>([A-Z]+0?\s)*?([A-Z]+[1-2]))(?<difference>((\s[A-Z]+)(?=\s|$))*)/
  @@d = CMUDict.new

  attr_reader :string

  def initialize(string)
    @string = string
  end

  def r_matches
    return @r_matches if @r_matches
    @r_matches = get_r_matches rescue []
  end

  def pronunciations
    return @pronunciations if @pronunciations
    @pronunciations = string_to_pronunciations 
  end

  def string_to_pronunciations
    return '' if /[[:punct:]]/.match(@string)
    @@d.dict[@string.upcase] || nil
  end

  def rhymes_with?(other)
    check_match_combinations_for_rhyme(r_matches, other.r_matches)
  end

  def get_r_matches
    @r_matches = pronunciations.collect do |p|
      @@r.match(p.split.reverse.join(' '))
    end
  end

  def stop?
    return @stop if @stop
    @stop = /[\.\!\?]/.match(@string) ? true : false
  end

  def check_match_pair_for_rhyme(match_a, match_b)
    return false unless match_a and match_b
    match_a['similarity'] == match_b['similarity'] and
    match_a['difference'] != match_b['difference']
  end

  def check_match_combinations_for_rhyme(r_matches_a, r_matches_b)
    r_matches_a.product(r_matches_b).each do |c|
      return true if check_match_pair_for_rhyme(c[0], c[1])
    end
    return false
  end

end  
