# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "localeapp/version"

Gem::Specification.new do |s|
  s.name        = "localeapp"
  s.version     = Localeapp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell", "Chris McGrath", "Michael Baudino", "Thibault Dalban"]
  s.email       = ["chris@tigrish.com", "chris@octopod.info", "michael.baudino@alpine-lab.com", "thibault.dalban@alpine-lab.com"]
  s.homepage    = "http://www.localeapp.com"
  s.summary     = %q{Easy i18n translation management with localeapp.com}
  s.description = %q{Synchronizes i18n translation keys and content with localeapp.com so you don't have to manage translations by hand.}
  s.license     = 'MIT'

  s.rubyforge_project = "localeapp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.1"

  s.add_dependency('i18n', '>= 0.7', '< 2')
  s.add_dependency('json', '>= 1.7.7')
  s.add_dependency('rest-client', '>= 1.8.0')
  s.add_dependency('gli')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 3.3')
  s.add_development_dependency('yard')
  s.add_development_dependency('aruba', '~> 0.8')
  s.add_development_dependency('cucumber', '~> 2.0')
  s.add_development_dependency('fakeweb')
end
