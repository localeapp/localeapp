module LocaleApp
  module Routes

    def project_url
      URI::HTTP.build(base_options.merge(:path => project_path)).to_s
    end

    def translations_url(options={})
      url = URI::HTTP.build(base_options.merge(:path => translations_path))
      url.query = options[:query].map { |k,v| "#{k}=#{v}" }.join('&') if options[:query]
      url.to_s
    end

  private

    def base_options
      options = {:host => LocaleApp.configuration.host, :port => LocaleApp.configuration.port}
      if LocaleApp.configuration.http_auth_username
        options[:userinfo] = "#{LocaleApp.configuration.http_auth_username}:#{LocaleApp.configuration.http_auth_password}"
      end
      options
    end

    def project_path
      "/api/projects/#{LocaleApp.configuration.api_key}"
    end

    def translations_path
      project_path << '/translations'
    end
  end
end