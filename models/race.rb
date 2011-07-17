class Race
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :username, Text, :required => true, :lazy => false
  property :created_at, DateTime
  property :in_progress, Boolean, :default => true
  property :duration, Float, :default => 0

  alias_method :started, :created_at
  alias_method :progress?, :in_progress

  belongs_to :track

  def stop(time)
    return false unless self.in_progress
    self.in_progress = false
    self.duration = time
    self.save
  end

  def self.best
    first(:order => [:duration.asc], :in_progress => false)
  end
end
