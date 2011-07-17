TheRaceApp.controllers :search do
  helpers do
  end

  post(:index, :provides => :json) { search_locations(params[:q]) }

  get(:index, :provides => :json) { search_locations(params[:q]) }
end
