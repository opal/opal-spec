require 'opal'
require File.expand_path('../lib/opal/spec/version', __FILE__)

desc "Build latest opal-spec to current dir"
task :browser do
  Opal::Builder.new('lib', :join => "opal-spec.js").build
end
