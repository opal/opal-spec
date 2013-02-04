require 'bundler/setup'
require 'opal-spec'

desc "Build opal-spec (with opal) into build"
task :build do
  File.open('build/opal-spec.js', 'w+') do |out|
    out.puts Opal.process('opal-spec')
  end
end

desc "Build example specs ready to run"
task :specs do
  Opal.append_path File.join(File.dirname(__FILE__), 'spec')

  File.open('build/opal-spec-specs.js', 'w+') do |out|
    out.puts Opal.process('specs')
  end
end
