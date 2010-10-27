# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "olba/version"

Gem::Specification.new do |s|
  s.name        = "olba"
  s.version     = Olba::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell"]
  s.email       = ["chris@tigrish.com"]
  s.homepage    = "http://rubygems.org/gems/olba"
  s.summary     = %q{Add missing translation keys to Hablo}
  s.description = %q{Post any unfound translation keys to the Hablo SaaS}

  s.rubyforge_project = "olba"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('yaml')
end
