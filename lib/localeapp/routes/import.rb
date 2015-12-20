module Localeapp
  module Routes
    module Import
      def import_endpoint(options = {})
        [:post, import_url(options)]
      end

      def import_url(options={})
        http_scheme.build(base_options.merge(:path => import_path)).to_s
      end

    private

      def import_path(format = nil)
        project_path << '/import/'
      end
    end
  end
end
