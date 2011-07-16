TheRaceApp.controllers :tracks do
  get :index, :provides => :json do
    { 
      :ok => true,
      :data => Track.all
    }.to_json
  end

  get :show, :with => :id, :provides => :json do
    track = Track.get(params[:id])
    {
      :ok => true,
      :data => track
    }.to_json
  end

  put :create, :provides => :json do
    track = Track.new(params)
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

  post :start, :map => ":id/start", :provides => :json do
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

  post :stop, :map => ":id/races/:race/stop", :provides => :json do
    track = Track.get(params[:id])
    race = track.races.first(:id => params[:race])
    race.stop(params[:time])

    {
      :ok => true,
      :data => {
        :time => race.duration,
        :won => (track.best_race == race),
        :winner => track.best_race.username
      }
    }.to_json
  end
end
