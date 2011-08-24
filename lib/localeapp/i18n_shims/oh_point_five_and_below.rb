puts "Using i18n <= 0.5.0 Shim" # temporary till we know Travis is setup properly
Localeapp::I18nMissingTranslationException = I18n::MissingTranslationData
