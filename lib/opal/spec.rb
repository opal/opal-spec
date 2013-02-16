require 'opal'
require 'opal/spec/version'

module Opal
  module Spec
    VENDOR_PATH = File.join(File.dirname(__FILE__), '..', '..', 'vendor')
  end
end

# Just register our opal code path with opal build tools
Opal.append_path File.join(File.dirname(__FILE__), '..', 'assets', 'javascripts')
