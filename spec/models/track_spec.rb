require 'spec_helper'

describe "Track Model" do
  before { DataMapper.auto_migrate! }
  let(:track) { Track.gen }
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

  describe "#races" do
    it 'has many races' do
      track.races.should == []
    end
  end

  describe "#best_race" do
    it 'only returns races not in progress' do
      r1 = track.start_race("emma")
      r2 = track.start_race("judy")
      r3 = track.start_race("jerrol")

      track.best_race.should be_nil

      r2.stop(200)
      track.best_race.should == r2
    end
  end

  describe "#start_race" do
    let(:track) { Track.gen }
    let(:race) { @race }
    before do
      @race = track.start_race("emma")
    end

    it 'creates a new race' do
      race.should be_a(Race)
    end

    it 'sets the name of the race to the name provided' do
      race.username.should == "emma"
    end

    it 'logs the begin time' do
      race.started.should_not be_nil
      race.started.should be_a(DateTime)
    end

    it 'sets the race to in progress' do
      race.progress?.should == true
    end
    
    context "stopping the race" do
      before do
        race.stop(600)
      end

      it 'cancels progress' do
        race.progress?.should == false
      end

      it 'sets the duration to provided number of seconds' do
        race.duration.should == 600
      end

      it 'sets the best race of the track to the race' do
        track.reload
        track.best_race.should == race
      end

      context "when a another race was faster" do
        before do
          track.start_race("willy").stop(500)
        end

        it 'the race will not be returned as best race' do
          track.best_race.should_not == race
        end
      end
      
      context "when a another race was slower" do
        before do
          track.start_race("sam").stop(700)
        end

        it 'the race will be returned as best race' do
          track.best_race.should == race
        end
      end
    end
  end

  describe "start point" do
    it 'sets the start point' do
      track.start_lat.should be_within(0.05).of(track.data.first["lat"].to_f)
      track.start_lng.should be_within(0.05).of(track.data.first["lon"].to_f)
    end

    it 'resolves the location' do
      track.start_city.should == "Amsterdam"
    end
  end
end
