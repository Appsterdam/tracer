TheRaceApp.controllers :search do
  helpers do
    def search_location
      { :origin => params[:q], :distance => 5.mi }
    end
  end

  get :index do
    tracks = Track.all(:start.near => search_location)
    {
      :ok => true,
      :data => tracks.map { |t|
        { :name => t.name,
          :id => t.id, 
          :uri => url(:tracks, :show, :id => t.id)
        }
      }
    }.to_json
  end
end
