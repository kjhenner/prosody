require File.expand_path '../../spec_helper.rb', __FILE__

describe 'stresses' do
  it 'turns a string into a stress pattern' do
    expect(stresses('But though I starve, and to my death still mourn,'))
      .to include("0101010111")
  end
end

describe 'meter_distance' do
  it "returns the levenshtein distance between a string and metrical pattern" do
    expect(meter_distance('But though I starve, and to my death still mourn,', IAMBIC))
      .to eq(1)
  end
  it "behaves reasonably with missing pronunciation data" do
    expect(meter_distance('But though I am iambic, and to my death still mourn,', IAMBIC))
      .to eq(99)
  end
end
