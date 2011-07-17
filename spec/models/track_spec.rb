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

  describe "#start_lat" do
    it 'is set from data' do
      track.start_lat.should == track.data.first["lat"].to_f
    end
  end

  describe "#start_lng" do
    it 'is set from data' do
      track.start_lng.should == track.data.first["lon"].to_f
    end
  end

  describe "#geocode" do
    let(:track) { Track.make }

    it 'can be called' do
      track.should respond_to(:geocode)
    end

    it 'sets the city' do
      expect do
        track.geocode
      end.to change(track, :city).to("Amsterdam")
    end
    
    it 'sets the country' do
      expect do
        track.geocode
      end.to change(track, :country).to("Nederland")
    end
    
    it 'sets the street' do
      expect do
        track.geocode
      end.to change(track, :street).to("Jan van Galenstraat 323, Van Galenbuurt")
    end
  end

  describe "#data" do
    it 'is valid with format [{"lat":"52.372246","lon":"4.844971"}]' do
      track = Track.new(:name => "Super Track", :data => '[{"lat":"52.372246","lon":"4.844971"}]')
      track.should be_valid
      track.errors[:data].should be_empty
    end
    
    it 'is not valid if root is not an Array' do
      track = Track.new(:name => "Super Track", :data => '{}')
      track.should_not be_valid
      track.errors[:data].should_not be_empty
    end
    
    it 'is not valid with empty array []' do
      track = Track.new(:name => "Super Track", :data => '[]')
      track.should_not be_valid
      track.errors[:data].should_not be_empty
    end
    
    it 'is not valid if objects do not have a "lat" key' do
      track = Track.new(:name => "Super Track", :data => '[{"lon":123}]')
      track.should_not be_valid
      track.errors[:data].should_not be_empty
    end
    
    it 'is not valid if objects do not have a "lon" key' do
      track = Track.new(:name => "Super Track", :data => '[{"lat":123}]')
      track.should_not be_valid
      track.errors[:data].should_not be_empty
    end
  end

  describe "#winner" do
    it 'returns the winner' do
      track.start_race("johnny").stop(600)
      track.start_race("emma").stop(500)
      track.start_race("judy").stop(700)
      
      track.winner.should == "emma"
    end

    it 'returns an empty string of there is no winner' do
      track.winner.should == ""
    end
  end
  
  describe "#best_time" do
    it 'returns the best time' do
      track.start_race("johnny").stop(600)
      track.start_race("emma").stop(500)
      track.start_race("judy").stop(700)
      
      track.best_time.should == 500
    end
    
    it 'returns 0 of there is no best time' do
      track.best_time.should == 0
    end
  end

  describe ".near" do
    before { seed_tracks }

    it 'returns the tracks near the location' do
      Track.near("Amsterdam").to_a.size.should == 2
    end
  end
end
