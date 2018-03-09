require "localeapp/routes/base"
require "localeapp/routes/projects"
require "localeapp/routes/translations"
require "localeapp/routes/export"
require "localeapp/routes/remove"
require "localeapp/routes/rename"
require "localeapp/routes/missing_translations"
require "localeapp/routes/import"
require "localeapp/routes/copy"

module Localeapp
  module Routes
    VERSION = 'v1'

    include Base
    include Projects
    include Translations
    include Export
    include Remove
    include Rename
    include MissingTranslations
    include Import
    include Copy
  end
end
