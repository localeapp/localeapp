module LocaleApp
  class ExceptionHandler
    def self.call(exception, locale, key, options)
      LocaleApp.log(exception.message)
      if I18n::MissingTranslationData === exception
        LocaleApp.log('Detected missing translation')

        LocaleApp.missing_translations.add(locale, key, options)

        [locale, key].join(', ')
      else
        LocaleApp.log('Raising exception')
        raise
      end
    end
  end
end

I18n.exception_handler = LocaleApp::ExceptionHandler
