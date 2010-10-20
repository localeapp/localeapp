module I18n
  class << self
    def obla_exception_handler(exception, locale, key, options)
      Olba.log(exception.message)
      if MissingTranslationData === exception
        Olba.log('Detected missing translation')
        Olba.sender.post_translation(locale, key, options)
        [locale, key].join(', ')
      else
        Olba.log('Raising exception')
        raise exception
      end
    end

  end
end

I18n.exception_handler = :obla_exception_handler
