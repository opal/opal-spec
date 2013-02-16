require 'opal/spec'
require 'erb'

module Opal
  module Spec
    class Server
      class Index
        def initialize(app, sprockets)
          @app = app
          @sprockets = sprockets
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
          paths = @sprockets[source].to_a.map { |d| "#{d.logical_path}?body=1" }
          tags  = paths.map { |p| "<script src=\"/assets/#{p}\"></script>" }
          tags.join "\n"
        end
      end

      def initialize
        @sprockets = sprockets = Opal::Environment.new
        sprockets.append_path 'spec'

        @app = Rack::Builder.app do
          map('/assets') { run sprockets }
          use Index, sprockets
          run Rack::Directory.new('spec')
        end
      end

      def call(env)
        @app.call env
      end
    end
  end
end
