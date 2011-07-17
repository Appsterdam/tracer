PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

# force loading of all controllers
Dir[File.expand_path('app/controllers/*', Padrino.root)].each { |f| require f }

# load fixtures
Dir[File.join(Padrino.root, 'spec/fixtures/*.rb')].each { |f| require f }

RSpec.configure do |conf|
  conf.mock_with :mocha
  conf.include Rack::Test::Methods
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  TheRaceApp.tap { |app|  }
end

def stub_google_map_api
   loc = Geokit::Geocoders::GoogleGeocoder.geocode "Tt. Neveritaweg 61, Amsterdam"
   Geokit::Geocoders::GoogleGeocoder.stubs(:geocode).returns(loc)
end

