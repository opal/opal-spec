require 'opal/spec'
require 'erb'

module Opal
  module Spec
    class Server
      class Index
        def initialize(app, server)
          @app = app
          @server = server
        end

        def call(env)
          if env['PATH_INFO'] == '/'
            [200, { 'Content-Type' => 'text/html' }, [self.html]]
          else
            @app.call env
          end
        end

        def html
          source = File.read File.join(VENDOR_PATH, 'spec_runner.html.erb')
          ERB.new(source).result binding
        end

        def javascript_include_tag(source)
          if @server.debug
            paths = sprockets[source].to_a.map { |d| "#{d.logical_path}?body=1" }
            tags  = paths.map { |p| "<script src=\"/assets/#{p}\"></script>" }
            tags.join "\n"
          else
            "<script src=\"/assets/#{source}.js\"></script>"
          end
        end

        def sprockets
          @server.sprockets
        end
      end

      attr_reader :sprockets
      attr_reader :debug

      def initialize(debug = true)
        @debug = debug
        server = self

        @sprockets = sprockets = Opal::Environment.new
        @sprockets.append_path 'spec'

        @app = Rack::Builder.app do
          map('/assets') { run sprockets }
          use Index, server
          run Rack::Directory.new('spec')
        end
      end

      def call(env)
        @app.call env
      end
    end
  end
end
