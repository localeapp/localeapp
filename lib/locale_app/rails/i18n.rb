module I18n
  class << self
    def locale_app_exception_handler(exception, locale, key, options)
      LocaleApp.log(exception.message)
      if MissingTranslationData === exception
        LocaleApp.log('Detected missing translation')
        LocaleApp.sender.post_translation(locale, key, options)
        [locale, key].join(', ')
      else
        LocaleApp.log('Raising exception')
        raise
      end
    end

  end
end

I18n.exception_handler = :locale_app_exception_handler
