require 'i18n'
require 'locale_app'
require 'fakeweb'
require 'support/locale_app_integration_data'
require 'logger'

def with_configuration(options = {})
  LocaleApp.configuration = nil
  LocaleApp.configure do |configuration|
    options.each do |option, value| 
      configuration.send("#{option}=", value)
    end
  end
  yield
end

RSpec.configure do |config|
  config.include(LocaleAppIntegrationData)
  config.before(:each) do
    FakeWeb.allow_net_connect = false
  end
end
