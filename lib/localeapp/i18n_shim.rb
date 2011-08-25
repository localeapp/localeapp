if defined? I18n::MissingTranslation 
  Localeapp::I18nMissingTranslationException = I18n::MissingTranslation
else
  Localeapp::I18nMissingTranslationException = I18n::MissingTranslationData
end
