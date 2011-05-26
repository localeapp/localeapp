module LocaleApp
  MissingTranslationRecord = Struct.new(:key, :locale, :options)

  class MissingTranslations
    def initialize
      @translations = Hash.new { |h, k| h[k] = {} }
    end

    def add(locale, key, options)
      record = MissingTranslationRecord.new(key, locale, options)
      @translations[locale][key] = record
    end

    def [](locale)
      @translations[locale]
    end
  end
end
