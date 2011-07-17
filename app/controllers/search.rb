TheRaceApp.controllers :search do
  get :index, :provides => :json do
    tracks = Track.near(params[:q])
    {
      :ok => true,
      :data => tracks.map { |t| prepare_track(t) }
    }.to_json
  end
  
  post :index, :provides => :json do
    tracks = Track.near(params[:q])
    {
      :ok => true,
      :data => tracks.map { |t| prepare_track(t) }
    }.to_json
  end
end
