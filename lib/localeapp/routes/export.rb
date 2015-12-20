module Localeapp
  module Routes
    module Export
      def export_endpoint(options = {})
        [:get, export_url(options)]
      end

      def export_url(options = {})
        options[:format] ||= 'yml'
        url = http_scheme.build(base_options.merge(:path => export_path(options[:format])))
        url.query = options[:query].map { |k,v| "#{k}=#{v}" }.join('&') if options[:query]
        url.to_s
      end

      private

      def export_path(format = nil)
        path = project_path << '/translations/all'
        path << ".#{format}" if format
        path
      end
    end
  end
end
