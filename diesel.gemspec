# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'diesel/version'

Gem::Specification.new do |s|
  s.name        = "diesel"
  s.version     = Diesel::VERSION
  s.authors     = ["Kyle Brett"]
  s.email       = ["kyle@vitrue.com"]
  s.homepage    = "http://github.com/vitrue/diesel"
  s.summary     = %q{Parameter validation and request routing DSL & framework}
  s.description = %q{Diesel includes every single limit.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'activesupport'
end
