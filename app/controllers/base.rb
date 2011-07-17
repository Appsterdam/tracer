TheRaceApp.controllers do
  get :index, :provides => :json do
    routes = []
    Padrino.mounted_apps.each do |a|
      app_routes = a.named_routes
      # app_routes.reject! { |r| r.identifier.to_s !~ /#{args.query}/ } if args.query.present?
      app_routes.each { |r| routes << r.path }
    end
    {
      :ok => true,
      :message => "Available paths",
      :data => routes
    }.to_json
  end
end
