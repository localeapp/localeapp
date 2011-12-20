module Localeapp
  module Routes
    VERSION = 'v1'

    def project_endpoint(options = {})
      [:get, project_url(options)]
    end

    def project_url(options = {})
      options[:format] ||= 'json'
      http_scheme.build(base_options.merge(:path => project_path(options[:format]))).to_s
    end

    def translations_url(options={})
      options[:format] ||= 'yml'
      url = http_scheme.build(base_options.merge(:path => translations_path(options[:format])))
      url.query = options[:query].map { |k,v| "#{k}=#{v}" }.join('&') if options[:query]
      url.to_s
    end

    def translations_endpoint(options = {})
      [:get, translations_url(options)]
    end

    def create_translation_endpoint(options = {})
      [:post, translations_url(options)]
    end

    def missing_translations_endpoint(options = {})
      [:post, missing_translations_url(options)]
    end

    def missing_translations_url(options={})
      options[:format] ||= 'json'
      url = http_scheme.build(base_options.merge(:path => missing_translations_path(options[:format])))
      url.query = options[:query].map { |k,v| "#{k}=#{v}" }.join('&') if options[:query]
      url.to_s
    end

    def import_endpoint(options = {})
      [:post, import_url(options)]
    end

    def import_url(options={})
      http_scheme.build(base_options.merge(:path => import_path)).to_s
    end

  private
    def http_scheme
      if Localeapp.configuration.secure
        URI::HTTPS
      else
        URI::HTTP
      end
    end

    def base_options
      options = {:host => Localeapp.configuration.host, :port => Localeapp.configuration.port}
      if Localeapp.configuration.http_auth_username
        options[:userinfo] = "#{Localeapp.configuration.http_auth_username}:#{Localeapp.configuration.http_auth_password}"
      end
      options
    end

    def project_path(format = nil)
      path = "/#{VERSION}/projects/#{Localeapp.configuration.api_key}"
      path << ".#{format}" if format
      path
    end

    def translations_path(format = nil)
      path = project_path << '/translations'
      path << ".#{format}" if format
      path
    end

    def missing_translations_path(format = nil)
      path = project_path << '/translations/missing'
      path << ".#{format}" if format
      path
    end

    def import_path(format = nil)
      project_path << '/import/'
    end
  end
end
