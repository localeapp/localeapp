require 'i18n'
require 'localeapp'
require 'fakeweb'
require 'logger'

Dir["spec/support/**/*.rb"].map { |e| require e.gsub 'spec/', '' }

I18n.config.available_locales = :en

def with_configuration(options = {})
  Localeapp.configuration = nil
  Localeapp.configure do |configuration|
    options.each do |option, value|
      configuration.send("#{option}=", value)
    end
  end
  yield
end

RSpec.configure do |config|
  config.include(LocaleappIntegrationData)
  config.include(LocaleappSynchronizationData)
  config.before(:each) do
    FakeWeb.allow_net_connect = false
  end
end
