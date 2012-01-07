require 'opal'

desc "Build latest opal-spec to current dir"
task :opal do
  Opal::Builder.new('lib', :join => "opal-spec.js").build
end

desc "Get all running dependnecies"
task :dependencies do
  Opal::DependencyBuilder.new(opal: true, verbose: true).build
end
