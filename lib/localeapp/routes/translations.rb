module Localeapp
  module Routes
    module Translations
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

    private

      def translations_path(format = nil)
        path = project_path << '/translations'
        path << ".#{format}" if format
        path
      end
    end
  end
end
