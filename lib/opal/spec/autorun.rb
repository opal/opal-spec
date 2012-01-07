require 'opal/spec'

# If autorun is the main file (entry point), then automatically load all
# specs from spec/
if $0 == __FILE__
  Dir['spec/**/*.rb'].each do |spec|
   require spec
  end
end

OpalSpec::Runner.autorun
