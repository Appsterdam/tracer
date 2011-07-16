class Track
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, Text, :required => true, :lazy => false
end
