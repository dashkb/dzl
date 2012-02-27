# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'diesel/version'

Gem::Specification.new do |s|
  s.name        = "diesel"
  s.version     = Diesel::VERSION
  s.authors     = ["Kyle Brett"]
  s.email       = ["kyle@vitrue.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'activesupport'
end
