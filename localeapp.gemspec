# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "locale_app/version"

Gem::Specification.new do |s|
  s.name        = "localeapp"
  s.version     = LocaleApp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell", "Chris McGrath"]
  s.email       = ["chris@tigrish.com", "chris@octopod.info"]
  s.homepage    = "http://rubygems.org/gems/localeapp"
  s.summary     = %q{Add missing translation keys to localeapp.com}
  s.description = %q{Post any unfound translation keys to the Locale SaaS}

  s.rubyforge_project = "localeapp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('ya2yaml')

  # i18n is a dev dependency as we'll use whichever version is in rails
  # when the gem runs
  s.add_development_dependency('i18n', '0.5.0')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '2.5.0')
  s.add_development_dependency('yard', '0.6.7')
  s.add_development_dependency('RedCloth', '4.2.7')
  s.add_development_dependency('aruba', '0.3.6')
  s.add_development_dependency('fakeweb', '1.3.0')
end
