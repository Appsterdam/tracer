# TODO: Move fix for json to initializer
class Fixnum
 def to_json(options = nil)
    to_s
  end
end

class Track
  include DataMapper::Resource
  include DataMapper::GeoKit

  # property <name>, <type>
  property :id, Serial
  property :name, Text, :required => true, :lazy => false
  property :data, Json, :required => true

  has_geographic_location :start

  has n, :races

  before :save do |t|
    t.start = "#{data.first["lat"]} #{data.first["lon"]}"
  end

  def best_race
    races.best
  end

  def start_race(username)
    races.create(:username => username)
  end
end
