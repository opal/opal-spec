require 'opal/spec'
require 'opal/spec/server'

module Opal
  module Spec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      attr_accessor :name
      attr_writer :runner_path, :url_path, :port

      def initialize(name = 'opal:spec')
        @name = name
        yield self if block_given?

        define_tasks
      end

      def define_tasks
        desc "Run opal specs in phantomjs"
        task @name do
          require 'rack'
          require 'webrick'

          server = fork do
            Rack::Server.start(:app => Opal::Spec::Server.new, :Port => port,
              :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
          end

          system "phantomjs #{runner_path} \"#{url_path}\""
          success = $?.success?

          Process.kill(:SIGINT, server)
          Process.wait

          exit 1 unless success
        end
      end

      def runner_path
        @runner_path || File.join(VENDOR_PATH, 'spec_runner.js')
      end

      def url_path
        @url_path || "http://localhost:9999/"
      end

      def port
        @port || 9999
      end
    end
  end
end
