TheRaceApp.helpers do
  def search_locations(q)
    tracks = Track.near(params[:q])
    {
      :ok => true,
      :data => tracks.map { |t| prepare_track(t) }
    }.to_json
  end
end
