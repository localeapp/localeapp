module Localeapp
  module Routes
    module Projects
      def project_endpoint(options = {})
        [:get, project_url(options)]
      end

      def project_url(options = {})
        options[:format] ||= 'json'
        http_scheme.build(base_options.merge(:path => project_path(options[:format]))).to_s
      end

    private

      def project_path(format = nil)
        path = "/#{VERSION}/projects/#{Localeapp.configuration.api_key}"
        path << ".#{format}" if format
        path
      end
    end
  end
end
