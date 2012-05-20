# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opal-spec/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'opal-spec'
  s.version      = OpalSpec::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam@adambeynon.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'Opal compatible spec'
  s.description  = 'Opal compatible spec'

  s.files          = `git ls-files`.split("\n")
  s.require_paths  = ['lib']
end
