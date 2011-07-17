# TODO: Move fix for json to initializer
class Fixnum
 def to_json(options = nil)
    to_s
  end
end

class Track
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, Text, :required => true, :lazy => false
  property :data, Json, :required => true

  property :start_lat, Float, :default => lambda { |r,p| r.data.first["lat"] rescue nil }
  property :start_lng, Float, :default => lambda { |r,p| r.data.first["lon"] rescue nil }
  property :city, String
  property :street, String
  property :country, String

  has n, :races

  before :create, :geocode

  validates_with_block :data do
    if !@data.is_a?(Array)
      [false, "Root object must be an Array"]
    elsif @data.empty?
      [false, "Data can not be empty"]
    elsif !@data.select { |l| l["lat"].blank? || l["lon"].blank? }.empty?
      [false, "All objects need a lat and a lon key"]
    else
      true
    end
  end

  def geocode
    loc = Geokit::Geocoders::GoogleGeocoder.geocode "#{self.start_lat} #{self.start_lng}"
    self.city    = loc.city
    self.street  = loc.street_address
    self.country = loc.country
    loc.success
  end

  def best_race
    races.best
  end

  def start_race(username)
    races.create(:username => username)
  end
end
