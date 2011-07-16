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
end
