require 'opal'
require File.expand_path('../lib/opal/spec/version', __FILE__)

namespace :browser do

  desc "Build latest opal-spec to current dir"
  task :build do
    Opal::Builder.new('lib', :join => 'opal-spec.js').build
  end

  desc "Debug version of opal-spec"
  task :debug do
    Opal::Builder.new('lib', :debug => true, :join => 'opal-spec.debug.js').build
  end
end

task :browser => :'browser:build'
