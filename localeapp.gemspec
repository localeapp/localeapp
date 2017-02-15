require File.expand_path("../lib/localeapp/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "localeapp"
  s.version     = Localeapp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Dell", "Chris McGrath", "Michael Baudino"]
  s.email       = %w[chris@tigrish.com chris@octopod.info michael.baudino@alpine-lab.com]
  s.homepage    = "http://www.localeapp.com/"
  s.summary     = %q{Easy i18n translation management with localeapp.com}
  s.description = %q{Synchronizes i18n translation keys and content with localeapp.com so you don't have to manage translations by hand.}
  s.license     = "MIT"

  s.files         = `git ls-files lib`.split $/
  s.executables   = "localeapp"

  s.required_ruby_version = ">= 2.1"

  s.add_dependency "i18n", "~> 0.4"
  s.add_dependency "json"
  s.add_dependency "rest-client"
  s.add_dependency "gli"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.3"
  s.add_development_dependency "aruba", "~> 0.8"
  s.add_development_dependency "cucumber", "~> 2.0"
  s.add_development_dependency "fakeweb"
end
