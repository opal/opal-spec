require 'opal'

require 'opal/spec/example'
require 'opal/spec/example_group'
require 'opal/spec/matchers'
require 'opal/spec/runner'
require 'opal/spec/scratch_pad'
require 'opal/spec/expectations'
require 'opal/spec/browser_formatter'
require 'opal/spec/phantom_formatter'
require 'opal/spec/kernel'

module Opal
  Spec = ::Spec   # Compatibility with older versions
end
