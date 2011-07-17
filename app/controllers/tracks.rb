TheRaceApp.controllers :tracks do
  get :index, :provides => :json do
    { 
      :ok => true,
      :data => Track.all.map { |t| prepare_track(t) }
    }.to_json
  end

  post :create, :provides => :json do
    track = Track.new({ :name => params[:name], :data => params[:data]})
    if track.save
      redirect url(:tracks, :show, :id => track.id, :format => content_type)
    else
      {
        :ok => false,
        :messages => track.errors,
        :data => params
      }.to_json
    end
  end

  post :start, :map => "/tracks/:id/start", :provides => :json do
    track = Track.get(params[:id])
    race = track.start_race(params[:username])
    {
      :ok => true,
      :data => {
        :race => race.id,
        :stop => url(:tracks, :stop, :id => track.id, :race => race.id, :format => content_type),
        :username => race.username,
        :started => race.started
      }
    }.to_json
  end

  post :stop, :map => "/tracks/:id/races/:race/stop", :provides => :json do
    track = Track.get(params[:id])
    race = track.races.first(:id => params[:race])
    if race.stop(params[:time])
      {
        :ok => true,
        :data => {
        :time => race.duration,
        :won => (track.best_race == race),
        :winner => track.winner,
        :best_time => track.best_time
      }
      }.to_json
    else
      {
        :ok => false,
        :message => "Race was already stopped"
      }.to_json
    end
  end

  get :show, :map => "/tracks/:id", :provides => :json do
    if track = Track.get(params[:id])
      {
        :ok => true,
        :data => prepare_track(track)
      }.to_json
    else
      status 404
      {
        :ok => false,
        :message => "Track was not found"
      }.to_json
    end
  end
end
