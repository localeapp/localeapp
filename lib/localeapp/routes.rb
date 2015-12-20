require 'rack/utils'

module Localeapp
  module Routes
    VERSION = 'v1'

    require "localeapp/routes/base"
    require "localeapp/routes/projects"
    require "localeapp/routes/translations"
    require "localeapp/routes/export"
    require "localeapp/routes/remove"
    require "localeapp/routes/rename"
    require "localeapp/routes/missing_translations"
    require "localeapp/routes/import"
  end
end
