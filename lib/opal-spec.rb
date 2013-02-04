require 'opal'
require 'opal-spec/version'

# Just register our opal code path with opal build tools
Opal.append_path File.join(File.dirname(__FILE__), 'assets', 'javascripts')
