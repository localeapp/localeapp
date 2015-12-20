module Localeapp
  module Routes
    module Rename
      def rename_endpoint(options = {})
        [:post, rename_url(options)]
      end

      def rename_url(options = {})
        url = http_scheme.build(base_options.merge(:path => rename_path(options[:current_name], options[:format])))
        url.to_s
      end

    private

      def rename_path(current_name, format = nil)
        raise "rename_path requires current name" if current_name.nil?
        path = translations_path << "/#{escape_key(current_name)}" << '/rename'
        path << ".#{format}" if format
        path
      end

    end
  end
end
