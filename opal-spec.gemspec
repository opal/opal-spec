$:.push File.expand_path('../lib', __FILE__)
require 'opal/spec/version'

Gem::Specification.new do |s|
  s.name         = 'opal-spec'
  s.version      = OpalSpec::VERSION
  s.authors      = ['Adam Beynon']
  s.email        = ['adam@adambeynon.com']
  s.homepage     = 'http://opalscript.org'
  s.summary      = 'Opal spec lib'
  s.description      = 'Opal spec lib'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
end
