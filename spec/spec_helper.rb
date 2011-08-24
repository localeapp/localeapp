require 'i18n'
require 'localeapp'
require 'fakeweb'
require 'support/localeapp_integration_data'
require 'support/localeapp_synchronization_data'
require 'support/i18n/missing_translation'
require 'logger'

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
