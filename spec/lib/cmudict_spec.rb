require File.expand_path '../../spec_helper.rb', __FILE__

describe 'CMUDict' do
  d = CMUDict.new
  describe 'parse' do
    it 'parses the raw CMUDict and returns a hash' do
      expect(d.parse('data/cmudict')["ZYUGANOV"])
      .to eq(["Z Y UW1 G AA0 N AA0 V", "Z UW1 G AA0 N AA0 V"])
    end
  end
  describe 'serialize' do
    it 'saves the parsed hash as a json file' do
      d.serialize
    end
  end
end
