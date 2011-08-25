if defined? I18n::MissingTranslation 
  puts "Using i18n >= 0.6.0" # temporary till we know Travis is setup properly
  Localeapp::I18nMissingTranslationException = I18n::MissingTranslation
else
  puts "Using i18n <= 0.5.0" # temporary till we know Travis is setup properly
  Localeapp::I18nMissingTranslationException = I18n::MissingTranslationData
end
