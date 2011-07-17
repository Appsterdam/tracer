class TheRaceApp < Padrino::Application
  register Padrino::Helpers
  register GeoInitializer

  error 404 do
    content_type :json
    { :ok => false, :message => "Not found" }.to_json
  end

  error 500 do
    content_type :json
    { :ok => false, :message => "Something went wrong" }.to_json
  end
end
