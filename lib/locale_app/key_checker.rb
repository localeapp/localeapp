require 'yaml'
require 'rest-client'
require 'time'

module LocaleApp
  class KeyChecker
    include ::LocaleApp::Routes

    def check(key)
      begin
        if LocaleApp.configuration.nil? # no config file yet
          LocaleApp.configuration = LocaleApp::Configuration.new
          LocaleApp.configuration.host = ENV['LA_TEST_HOST'] if ENV['LA_TEST_HOST']
        end
        LocaleApp.configuration.api_key = key
        response = RestClient.get(project_url)
        [true, JSON.parse(response)]
      rescue RestClient::ResourceNotFound => e
        [false, {}]
      end
    end
  end
end
