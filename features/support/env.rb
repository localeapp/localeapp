require 'aruba/cucumber'
require 'aruba/config/jruby'

require File.expand_path(File.join(File.dirname(__FILE__), '../../spec/support/localeapp_integration_data'))
World(LocaleappIntegrationData)

module FakeWebHelper
  def add_fake_web_uri(method, uri, status, body, headers = {})
    fakes = YAML.load(aruba.environment['FAKE_WEB_FAKES'] || '[]')
    fakes << {
      'method' => method,
      'uri' => uri,
      'status' => status,
      'body' => body,
      'headers' => headers
    }
    set_environment_variable 'FAKE_WEB_FAKES', YAML.dump(fakes)
  end
end
World(FakeWebHelper)
