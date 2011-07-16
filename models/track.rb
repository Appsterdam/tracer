class Track
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, Text, :required => true, :lazy => false

  has n, :races

  def best_race
    races.best
  end

  def start_race(username)
    races.create(:username => username)
  end
end
