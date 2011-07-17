require 'spec_helper'

describe "TracksController" do
  let(:json) { JSON.parse(last_response.body) }
  let(:valid_data) { Track.make.data.to_json }

  before do
    DataMapper.auto_migrate!
  end

  before do
    get "/"
  end

  describe "GET /tracks.json" do
    before(:all) { stub_google_map_api }

    before do
      3.times { Track.gen }
      get TheRaceApp.url(:tracks, :index)
    end

    it 'responds 200 ok' do
      last_response.should be_ok
    end

    it 'returns json' do
      last_response.content_type.should =~ %r{application/json}
    end

    it 'returns all the tracks in the "data" key' do
      json['data'].size.should == 3
    end

    it 'returns true in the "ok" key' do
      json['ok'].should == true
    end

    describe "track data" do
      let(:data) { json["data"].first }

      it 'has "data.name"' do
        data["name"].should be_a String
      end
      
      it 'has "data.best_time"' do
        data["best_time"].should be_a Fixnum
      end

      it 'has "data.winner"' do
        data["winner"].should be_a String
      end
      
      it 'has "data.data"' do
        data["data"].should be_a Array
      end

      it 'has "data.start_uri"' do
        data["start_uri"].should be_a String
      end

      it 'has "data.uri"' do
        data["uri"].should be_a String
      end
    end
  end

  describe "GET tracks/1.json" do
    let(:track) { Track.gen }
    
    before do
      track
      get TheRaceApp.url(:tracks, :show, :id => track.id)
    end

    it 'responds 200 ok' do
      last_response.should be_ok
    end

    it 'returns json' do
      last_response.content_type.should =~ %r{application/json}
    end

    it 'set the ok key to true' do
      json['ok'].should == true
    end

    context '"data" key' do
      let(:data) { json["data"] }

      it 'stores the name of the track' do
        data["name"].should == track.name
      end
      
      it 'stores the start uri of the track' do
        data["start_uri"].should == TheRaceApp.url(:tracks, :start, :id => track.id, :format => :json)
      end
    end

    context "when the resource does not exist" do
      before do
        get TheRaceApp.url(:tracks, :show, :id => 1000)
      end

      it 'sets the status to 404' do
        last_response.status.should == 404
      end

      it 'responds with json' do
        last_response.content_type.should =~ %r{application/json}
      end
    end
  end

  describe "POST /tracks/1/start.json" do
    let(:track) { Track.gen }

    before do
      post TheRaceApp.url(:tracks, :start, :id => track.id), { :username => "emma", :data => valid_data }
    end

    it 'responds with json' do
      last_response.content_type.should =~ %r{application/json}
    end

    it 'creates an new race' do
      expect do
        post TheRaceApp.url(:tracks, :start, :id => track.id), { :username => "emma", :data => valid_data }
      end.to change(track.races, :count).by(1)
    end

    describe "json response" do
      it 'sets "ok" to true' do
        json["ok"].should == true
      end

      it 'stores the id of the race under the "data.race" key' do
        json["data"]["race"].should == track.races.last.id
      end

      it 'stores the stop uri of the race under the "data.stop" key' do
        json["data"]["stop"].should == TheRaceApp.url(:tracks, :stop, :id => track.id, :race => json["data"]["race"], :format => :json)
      end

      it 'stores the username under the "data.username" key' do
        json["data"]["username"].should == "emma"
      end
      
      it 'stores the start time under the "data.started" key' do
        json["data"]["started"].should_not be_nil
      end
    end
  end

  describe "POST /tracks/1/races/1/stop.json" do
    let(:track) { Track.gen }
    let(:race) { track.start_race("emma") }

    before do
      post TheRaceApp.url(:tracks, :stop, :id => track.id, :race => race.id), { :time => 600 }
    end

    it 'responds 200 ok' do
      last_response.should be_ok
    end

    it 'responds with json' do
      last_response.content_type.should =~ %r{application/json}
    end

    it 'stops the race' do
      race.reload
      race.progress?.should == false
    end

    describe "json data" do
      it 'sets the "ok" key to true' do
        json["ok"].should == true
      end

      it 'stores the time under the "data.time" key' do
        json["data"]["time"].should == 600
      end

      it 'set the "data.won" key to true if the race was won by the user' do
        json["data"]["won"].should == true
      end

      it 'sets the "data.winner" key to the username of the user with the best time' do
        json["data"]["winner"].should == track.best_race.username
      end
    end

    describe "if the race was already stopped" do
      before do
        post TheRaceApp.url(:tracks, :stop, :id => track.id, :race => race.id), { :time => 600 }
      end

      it 'sets the "ok" key to false' do
        json["ok"].should == false
      end

      it 'sets the "message" key' do
        json["message"].should_not be_nil
      end
    end
  end

  describe "POST /tracks.json" do
    before do
      DataMapper.auto_migrate!
    end

    it 'creates a new track' do
      expect do
        post TheRaceApp.url(:tracks, :create), { :name => "A new track name", :data => valid_data }
      end.to change(Track, :count).by(1)
    end

    it 'redirects to the created resource' do
      post TheRaceApp.url(:tracks, :create), { :name => "A new track name", :data => valid_data }
      last_response.location.should == "http://example.org" + TheRaceApp.url(:tracks, :show, :id => Track.last.id, :format => :json)
    end

    context "invalid data" do
      it 'sets the "ok" key to false' do
        post TheRaceApp.url(:tracks, :create), { :name => nil }
        json["ok"].should == false
      end

      it 'sets the "messages" key to the error messages' do
        post TheRaceApp.url(:tracks, :create), { :name => nil }
        json["messages"].should_not be_nil
        json["messages"].should_not be_empty
      end
      
      it 'sets the "data" key to the putted data' do
        post TheRaceApp.url(:tracks, :create), { :name => nil }
        json["data"].should == { "name" => nil }
      end
    end
  end
end
