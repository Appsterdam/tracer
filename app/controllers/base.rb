TheRaceApp.controllers do
  get :index, :provides => :json do
    routes = []
    Padrino.mounted_apps.each do |a|
      app_routes = a.named_routes
      app_routes.each { |r| routes << r.path }
    end

    {
      :ok => true,
      :message => "Available paths",
      :data => routes
    }.to_json
  end

  get :clear, :provides => :json do
    DataMapper.auto_migrate!
    {
      :ok => true,
      :message => "Cleared database"
    }.to_json
  end
  
  get :seed, :provides => :json do
    require File.expand_path('db/seeds', Padrino.root)
    {
      :ok => true,
      :message => "Database seeded"
    }.to_json
  end
end
