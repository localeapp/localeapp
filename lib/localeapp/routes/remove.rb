module Localeapp
  module Routes
    module Remove
      def remove_endpoint(options = {})
        [:delete, remove_url(options)]
      end

      def remove_url(options = {})
        url = http_scheme.build(base_options.merge(:path => remove_path(options[:key], options[:format])))
        url.to_s
      end

    private

      def remove_path(key, format = nil)
        raise "remove_path requires a key" if key.nil?
        path = translations_path << "/#{escape_key(key)}"
        path << ".#{format}" if format
        path
      end
    end
  end
end
