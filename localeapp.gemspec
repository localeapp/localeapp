# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "localeapp/version"

Gem::Specification.new do |s|
  s.name        = "localeapp"
  s.version     = Localeapp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell", "Chris McGrath"]
  s.email       = ["chris@tigrish.com", "chris@octopod.info"]
  s.homepage    = "http://www.localeapp.com"
  s.summary     = %q{Easy i18n translation management with localeapp.com}
  s.description = %q{Synchronizes i18n translation keys and content with localeapp.com so you don't have to manage translations by hand.}
  s.license     = 'MIT'

  s.rubyforge_project = "localeapp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('i18n')
  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('rack')
  s.add_dependency('ya2yaml')
  s.add_dependency('gli')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.14.1')
  s.add_development_dependency('yard')
  s.add_development_dependency('RedCloth')
  s.add_development_dependency('aruba')
  s.add_development_dependency('fakeweb')
end
