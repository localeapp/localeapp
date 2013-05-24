module Localeapp
  module ExceptionHandler
    def call(exception, locale, key, options)
      Localeapp.log(exception.message)

      # Which exact exception is set up by our i18n shims
      if exception.is_a? Localeapp::I18nMissingTranslationException
        Localeapp.log("Detected missing translation for key(s) #{key.inspect}")

        [*key].each do |k|
          Localeapp.missing_translations.add(locale, k, nil, options || {})
        end

        super
      else
        super
      end
    end
  end
end

module I18n
  class ExceptionHandler
    include Localeapp::ExceptionHandler
  end
end
