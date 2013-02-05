# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opal/spec/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'opal-spec'
  s.version      = Opal::Spec::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam.beynon@gmail.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'Opal compatible spec'
  s.description  = 'Opal compatible spec library'

  s.files          = `git ls-files`.split("\n")
  s.require_paths  = ['lib']
end
