require 'spec_helper'

describe "SearchController" do
  describe "GET /search.json?q=location" do
    before { seed_tracks }

    it 'finds a point near the location' do
      get app.url(:search, :index, :q => "Amsterdam, The Netherlands")
      JSON.parse(last_response.body)["data"].size.should == 2
    end
  end
end
