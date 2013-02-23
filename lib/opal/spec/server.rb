require 'opal/spec'
require 'opal'

module Opal
  module Spec

    # Custom Opal::Server subclass which adds the 'spec' dir as a
    # directory for testing (adds to load path). Specs run through this
    # server are not run in debug mode (all scripts loaded in a single
    # file). This can be overriden in the supplied block.
    class Server < Opal::Server
      def initialize(*args, &block)
        super(*args) do |s|
          s.append_path 'spec'
          s.main = 'opal/spec/sprockets_runner'
          s.debug = false

          yield s if block_given?
        end
      end
    end
  end
end
