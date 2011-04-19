module LocaleApp
  module Routes

    def project_url
      URI::HTTP.build(base_options.merge(:path => "/api/projects/#{LocaleApp.configuration.api_key}")).to_s
    end

    def translations_url
      project_url << '/translations'
    end

    def base_options
      options = {:host => LocaleApp.configuration.host, :port => LocaleApp.configuration.port}
      if LocaleApp.configuration.http_auth_username
        options[:userinfo] = "#{LocaleApp.configuration.http_auth_username}:#{LocaleApp.configuration.http_auth_password}"
      end
      options
    end
  end
end