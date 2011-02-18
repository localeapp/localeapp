# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "locale_app/version"

Gem::Specification.new do |s|
  s.name        = "locale_app"
  s.version     = LocaleApp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell", "Chris McGrath"]
  s.email       = ["chris@tigrish.com", "chris@octopod.info"]
  s.homepage    = "http://rubygems.org/gems/locale_app"
  s.summary     = %q{Add missing translation keys to Hablo}
  s.description = %q{Post any unfound translation keys to the Hablo SaaS}

  s.rubyforge_project = "locale_app"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('i18n')
  
  s.add_development_dependency('rspec')
end
