require 'aruba/cucumber'
require 'aruba/jruby'

require File.expand_path(File.join(File.dirname(__FILE__), '../../spec/support/localeapp_integration_data'))
World(LocaleappIntegrationData)

module FakeWebHelper
  def add_fake_web_uri(method, uri, status, body, headers = {})
    fakes = JSON.parse(ENV['FAKE_WEB_FAKES'] || '[]')
    fakes << {
      'method' => method,
      'uri' => uri,
      'status' => status,
      'body' => body,
      'headers' => headers
    }
    ENV['FAKE_WEB_FAKES'] = fakes.to_json
  end
end
World(FakeWebHelper)

After do
  ENV.delete 'FAKE_WEB_FAKES'
end
