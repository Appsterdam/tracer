module GeoInitializer
  def self.registered(app)
    ::Geokit::Geocoders::google = ENV['GOOGLE_MAPS_API_KEY']
  end
end
