module Localeapp
  MissingTranslationRecord = Struct.new(:key, :locale, :description, :options)

  class MissingTranslations

    @@sent_keys = []

    def initialize
      @translations = Hash.new { |h, k| h[k] = {} }
    end

    def add(locale, key, description = nil, options = {})
      options.delete(:default) if locale != I18n.default_locale
      record = MissingTranslationRecord.new(key, locale, description, options)
      @translations[locale][key] = record
    end

    def [](locale)
      @translations[locale]
    end

    def to_send
      data = []
      # need the sort to make specs work under 1.8
      @translations.sort { |a, b| a.to_s <=> b.to_s }.each do |locale, records|
        records.each do |key, record|
          # Check to see if we've sent this key up already
          if Localeapp.configuration.cache_missing_translations
            next if @@sent_keys.include?(key)
            @@sent_keys << key
          end

          missing_data = {}
          missing_data[:key] = key
          missing_data[:locale] = locale
          missing_data[:description] = record.description if record.description
          missing_data[:options] = record.options
          data << missing_data
        end
      end
      data
    end
  end
end
