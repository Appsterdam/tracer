class TheRaceApp < Padrino::Application
  register Padrino::Helpers
  register GeoInitializer

  error 404 do
    content_type :json
    { :ok => false, :message => "Not found" }
  end

  error 500 do
    content_type :json
    { :ok => false, :message => "Something went wrong" }
  end
end
