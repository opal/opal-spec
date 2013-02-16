require 'bundler'
Bundler.require

require 'opal/spec/server'
run Opal::Spec::Server.new
