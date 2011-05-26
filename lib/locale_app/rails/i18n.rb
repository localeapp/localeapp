class LocaleAppExceptionHandler
  def self.call(exception, locale, key, options)
    LocaleApp.log(exception.message)
    if I18n::MissingTranslationData === exception
      LocaleApp.log('Detected missing translation')

      unless LocaleApp.configuration.sending_disabled?
        LocaleApp.sender.post_translation(locale, key, options)
      end

      [locale, key].join(', ')
    else
      LocaleApp.log('Raising exception')
      raise
    end
  end
end

I18n.exception_handler = LocaleAppExceptionHandler
