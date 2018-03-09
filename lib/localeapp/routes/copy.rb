module Localeapp
  module Routes
    module Copy
      def copy_endpoint(options = {})
        [:post, copy_url(options)]
      end

      def copy_url(options = {})
        url = http_scheme.build(base_options.merge(:path => copy_path(options[:source_name], options[:format])))
        url.to_s
      end

    private

      def copy_path(source_name, format = nil)
        raise "copy_path requires source name" if source_name.nil?
        path = translations_path << "/#{escape_key(source_name)}" << "/copy"
        path << ".#{format}" if format
        path
      end

    end
  end
end
