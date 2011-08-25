module Localeapp
  class ExceptionHandler
    def self.call(exception, locale, key, options)
      Localeapp.log(exception.message)
      if [I18n::MissingTranslationData, I18n::MissingTranslation].include?(exception.class)
        Localeapp.log("Detected missing translation for key(s) #{key.inspect}")

        [*key].each do |key|
          Localeapp.missing_translations.add(locale, key, options)
        end

        [locale, key].join(', ')
      else
        Localeapp.log('Raising exception')
        raise
      end
    end
  end
end

I18n.exception_handler = Localeapp::ExceptionHandler
