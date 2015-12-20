module Localeapp
  module Routes
    module MissingTranslations
      def missing_translations_endpoint(options = {})
        [:post, missing_translations_url(options)]
      end

      def missing_translations_url(options={})
        options[:format] ||= 'json'
        url = http_scheme.build(base_options.merge(:path => missing_translations_path(options[:format])))
        url.query = options[:query].map { |k,v| "#{k}=#{v}" }.join('&') if options[:query]
        url.to_s
      end

    private

      def missing_translations_path(format = nil)
        path = project_path << '/translations/missing'
        path << ".#{format}" if format
        path
      end
    end
  end
end
