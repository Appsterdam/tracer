Track.fixture {{
  :name                  => (name = /\w+/.gen),
}}

# Square around infinite loop
Track.fixture(:loc1) {{
  :name                  => "Square around infinite loop",
  :data => %|[{"lat":"37.337545","lon":"-122.041454"},{"lat":"37.337681","lon":"-122.014503"},{"lat":"37.322666","lon":"-122.014332"},{"lat":"37.323076","lon":"-122.041969"}]|
}}


# Infinite loop
Track.fixture(:loc2) {{
  :name                  => "Infinite loop",
  :data => %|[{"lat":"37.330534","lon":"-122.030475"},{"lat":"37.331040","lon":"-122.028508"},{"lat":"37.333456","lon":"-122.029723"}]|
}}

# couple of blocks around infinite
Track.fixture(:loc3) {{
  :name => "couple of blocks around infinite",
  :data =>  %|[{"lat":"37.337272","lon":"-122.041454"},{"lat":"37.310516","lon":"-122.013645"}]|
}}

# Round through Amsterdam
Track.fixture(:loc4) {{
  :name => "Round through Amsterdam",
  :data => %|[{"lat":"52.367791","lon":"4.896040"},{"lat":"52.373451","lon":"4.887028"},{"lat":"52.376909","lon":"4.898529"},{"lat":"52.372141","lon":"4.900503"}]|
}}

# Grachtenrondje
Track.fixture(:loc5) {{
  :name => "Grachtenrondje",
  :data => %|[{"lat":"52.366638","lon":"4.884710"},{"lat":"52.368813","lon":"4.887071"},{"lat":"52.372350","lon":"4.883251"},{"lat":"52.369232","lon":"4.872265"},{"lat":"52.366140","lon":"4.877973"}]|
}}

# West to east Amsterdam
Track.fixture(:loc6) {{
  :name => "West to east Amsterdam",
  :data => %|[{"lat":"52.372246","lon":"4.844971"},{"lat":"52.372612","lon":"4.951487"}]|
}}

def seed_tracks
  (1...6).each do |i|
    Track.gen("loc#{1}")
  end
end

