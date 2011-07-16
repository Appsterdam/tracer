PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")


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

# load fixtures
Dir[File.join(Padrino.root, 'spec/fixtures/*.rb')].each { |f| require f }