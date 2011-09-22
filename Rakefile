$:.unshift File.expand_path("../../../../lib/")
require 'opal/rake/bundle_task'

Opal::Rake::BundleTask.new do |bundle|
  bundle.options = {
    :method_missing => true
  }
end

