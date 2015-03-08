class Type
  R = /^(?<similarity>([A-Z]+0?\s)*?([A-Z]+[1-2]))(?<difference>((\s[A-Z]+)(?=\s|$))*)/

  attr_reader :pronunciations
  attr_reader :r_matches

  def initialize(string, cmudict)
    @string = string
    @d = cmudict
    @pronunciations = string_to_pronunciations
    @r_matches = get_r_matches
  end

  def string_to_pronunciations
    @d.dict[@string.upcase] || throw(:not_in_phoneme_dict)
  end

  def rhymes_with?(other)
    check_match_combinations_for_rhyme(@r_matches, other.r_matches)
  end

  def get_r_matches
    @r_matches = @pronunciations.collect do |p|
      R.match(p.split.reverse.join(' '))
    end
  end

  def check_match_pair_for_rhyme(match_a, match_b)
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
