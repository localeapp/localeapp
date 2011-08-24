puts "Using i18n >= 0.6.0 Shim" # temporary till we know Travis is setup properly
Localeapp::I18nMissingTranslationException = I18n::MissingTranslation
