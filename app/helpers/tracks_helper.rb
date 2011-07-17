TheRaceApp.helpers do
  def prepare_track(t)
    t.uri = url(:tracks, :show, :id => t.id, :format => content_type)
    t.start_uri = url(:tracks, :start, :id => t.id, :format => content_type)
    t
  end
end
