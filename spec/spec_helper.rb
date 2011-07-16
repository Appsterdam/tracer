PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

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

# def seed_tracks
#   track_data.each do |k,v|
#     puts k
#     Track.gen(:name => k, :data => v)
#   end
# end

