# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'dzl/version'

Gem::Specification.new do |s|
  s.name        = "dzl"
  s.version     = Dzl::VERSION
  s.authors     = ["Kyle Brett", "Paul Bergeron"]
  s.email       = ["kyle@vitrue.com", "pbergeron@vitrue.com"]
  s.homepage    = "http://github.com/vitrue/dzl"
  s.summary     = %q{Parameter validation and request routing DSL & web framework}
  s.description = %q{Small, fast racktivesupport web framework with handy DSL and explicit parameter validation.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack', '~> 1.4.1'
  s.add_runtime_dependency 'activesupport', '~> 3.2.2'
end
