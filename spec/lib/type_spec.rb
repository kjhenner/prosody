require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Type' do
  D = CMUDict.new
  t_a = Type.new('abduction')
  t_b = Type.new('fish')
  t_c = Type.new('dish')
  describe 'get_r_matches' do
    it 'sets and gets rhyme matches for self' do
      expect(t_a.get_r_matches[0]['similarity'])
      .to eq("N AH0 SH K AH1")
      expect(t_a.get_r_matches[0]['difference'])
      .to eq(" D B")
    end
  end
  describe 'string_to_pronunciations' do
    it 'gets a list of string representations of possible pronunciations' do
      expect(t_a.string_to_pronunciations)
      .to eq(["AE0 B D AH1 K SH AH0 N","AH0 B D AH1 K SH AH0 N"])
    end
  end
  describe 'check_match_pair_for_rhyme' do
    it 'returns true if a match pair rhymes' do
      expect(t_b.check_match_pair_for_rhyme(t_b.get_r_matches[0], t_c.get_r_matches[0]))
      .to eq(true)
    end
    it "returns false if a match pair doesn't rhyme" do
      expect(t_b.check_match_pair_for_rhyme(t_b.get_r_matches[0], t_a.get_r_matches[0]))
      .to eq(false)
    end
    it "returns false if a match pair is an identity" do
      expect(t_b.check_match_pair_for_rhyme(t_b.get_r_matches[0], t_b.get_r_matches[0]))
      .to eq(false)
    end
  end
  describe 'check_match_combinations_for_rhyme' do
    it 'returns true if any pronunciation combination rhymes' do
      expect(t_b.check_match_combinations_for_rhyme(t_b.get_r_matches, t_c.get_r_matches))
      .to eq(true)
    end
  end
  describe 'rhymes_with?' do
    it 'returns true if another word rhymes' do
      expect(t_b.rhymes_with?(t_c))
      .to eq(true)
    end
    it "returns true if another word doesn't rhyme" do
      expect(t_b.rhymes_with?(t_a))
      .to eq(false)
    end
  end
end
