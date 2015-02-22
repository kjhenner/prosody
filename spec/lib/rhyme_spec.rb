require File.expand_path '../../spec_helper.rb', __FILE__

describe "last_token" do
  it "returns the last token of a string" do
    expect(last_token("I want to 'eat', your popsicle but I can't."))
    .to eq("can't")
  end
end
describe "token_to_pronunciations" do
  it "finds pronunciations for a token with an apostrophe" do
    expect(token_to_pronunciations("can't", DICT))
    .to eq([[{"phoneme"=>"K", "stress"=>nil},
             {"phoneme"=>"AE", "stress"=>"1"},
             {"phoneme"=>"N", "stress"=>nil},
             {"phoneme"=>"T", "stress"=>nil}]])
  end
  it "finds all pronunciations for a token with multiple pronunciations" do
    expect(token_to_pronunciations("abduction", DICT))
    .to eq([[{"phoneme"=>"AE", "stress"=>"0"},
             {"phoneme"=>"B", "stress"=>nil},
             {"phoneme"=>"D", "stress"=>nil},
             {"phoneme"=>"AH", "stress"=>"1"},
             {"phoneme"=>"K", "stress"=>nil},
             {"phoneme"=>"SH", "stress"=>nil},
             {"phoneme"=>"AH", "stress"=>"0"},
             {"phoneme"=>"N", "stress"=>nil}],
            [{"phoneme"=>"AH", "stress"=>"0"},
             {"phoneme"=>"B", "stress"=>nil},
             {"phoneme"=>"D", "stress"=>nil},
             {"phoneme"=>"AH", "stress"=>"1"},
             {"phoneme"=>"K", "stress"=>nil},
             {"phoneme"=>"SH", "stress"=>nil},
             {"phoneme"=>"AH", "stress"=>"0"},
             {"phoneme"=>"N", "stress"=>nil}]])
  end
end
