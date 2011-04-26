module I18n
  class << self
    def locale_app_exception_handler(exception, locale, key, options)
      LocaleApp.log(exception.message)
      if MissingTranslationData === exception
        LocaleApp.log('Detected missing translation')
        
        unless LocaleApp.configuration.disabled?
          LocaleApp.sender.post_translation(locale, key, options)
        end

        [locale, key].join(', ')
      else
        LocaleApp.log('Raising exception')
        raise
      end
    end

  end
end

I18n.exception_handler = :locale_app_exception_handler
