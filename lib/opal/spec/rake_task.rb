require 'opal/spec'

module Opal
  module Spec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'spec_runner.js')
      PORT = 9999
      URL = "http://localhost:9999/"

      def initialize(name = 'opal:test', &block)
        desc "Run opal specs in phantomjs"
        task name do
          require 'rack'
          require 'webrick'

          server = fork do
            s = Opal::Server.new { |s|
              s.main = 'opal/spec/sprockets_runner'
              s.append_path 'spec'
              s.debug = false

              block.call s if block
            }

            Rack::Server.start(:app => s, :Port => PORT, :AccessLog => [],
              :Logger => WEBrick::Log.new("/dev/null"))
          end

          system "phantomjs #{RUNNER} \"#{URL}\""
          success = $?.success?

          Process.kill(:SIGINT, server)
          Process.wait

          exit 1 unless success
        end
      end
    end
  end
end
