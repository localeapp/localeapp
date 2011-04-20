require 'yaml'
require 'rest-client'
require 'time'

module LocaleApp
  class KeyChecker
    def check(key)
      begin
        response = RestClient.get(project_resource_url(key))
        [true, JSON.parse(response)]
      rescue RestClient::ResourceNotFound => e
        [false, {}]
      end
    end

    private
    def project_resource_url(key)
      if LocaleApp.configuration.nil? # no config file yet
        LocaleApp.configuration = LocaleApp::Configuration.new
      end
      uri_params = {
        :host => LocaleApp.configuration.host,
        :port => LocaleApp.configuration.port,
        :path => "/projects/#{key}.json"
      }
      if LocaleApp.configuration.http_auth_username
        uri_params[:userinfo] = "#{LocaleApp.configuration.http_auth_username}:#{LocaleApp.configuration.http_auth_password}"
      end
      URI::HTTP.build(uri_params).to_s
    end
  end
end
