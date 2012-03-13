# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'distil/version'

Gem::Specification.new do |s|
  s.name        = "distil"
  s.version     = Distil::VERSION
  s.authors     = ["Kyle Brett", "Paul Bergeron"]
  s.email       = ["kyle@vitrue.com", "pbergeron@vitrue.com"]
  s.homepage    = "http://github.com/vitrue/distil"
  s.summary     = %q{Parameter validation and request routing DSL & framework}
  s.description = %q{Distil includes every single limit.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'activesupport'
end
