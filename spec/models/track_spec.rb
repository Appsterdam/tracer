require 'spec_helper'

describe "Track Model" do
  let(:track) { Track.new }
  it 'can be created' do
    track.should_not be_nil
  end

  describe "#name" do
    it 'is required' do
      track.name = nil
      track.should_not be_valid
      track.errors[:name].should_not be_nil
    end
  end
end
