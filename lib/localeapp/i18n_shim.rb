module Localeapp
  if defined? I18n::MissingTranslation 
    I18nMissingTranslationException = I18n::MissingTranslation
  else
    I18nMissingTranslationException = I18n::MissingTranslationData
  end
end