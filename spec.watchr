# install watchr
# $ sudo gem install watchr
#
# Run With:
# $ watchr spec.watchr
#

# --------------------------------------------------
# Helpers
# --------------------------------------------------

def project
  {
    :name => File.basename(File.dirname(__FILE__))
  }
end

def notify(msg)
  system("growlnotify -n '#{project[:name]}' -t '#{project[:name]}' -m '#{msg}'")
end

def run(*cmds)
  system("clear")
  cmd = cmds.shift

  script = case cmd
           when :rspec then "rspec spec"
           when :features then "cucumber features"
           else
             "rspec #{cmd}"
           end

  msg = if success = system(script)
          "specs passed"
        else
          "specs failed"
        end
  notify(msg)

  run(*cmds) unless cmds.empty?
  run(:rspec) if success && ![:rspec, :features].find(cmd)
  return success
end

# run specs 
run(:rspec, :features)

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch("^lib/(.*)\.rb")                        { |m| run("spec/#{m[1]}_spec.rb") }
watch("^spec/(.*)_spec.rb")                   { |m| run("spec/#{m[1]}_spec.rb") }

watch("^lib/(.*)\.rb")                        { |m| run(:features) }
watch("^features/step_definitions/(.*)\.rb")  { |m| run(:features) }
watch("^features/(.*)\.feature")              { |m| run(:feature) }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all specs ---\n\n"
  run_all_specs
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }








