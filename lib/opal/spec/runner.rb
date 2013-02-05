module Opal
  module Spec

    # Run tests on the command line using phantomjs. Phantomjs **must** be
    # installed, and the runner assumes you have an HTML file at
    # ./spec/index.html which will be run.
    def self.runner
      runner = File.join File.dirname(__FILE__), '..', '..', '..', 'vendor', 'runner.js'
      system "phantomjs #{runner} spec/index.html"
    end
  end
end
