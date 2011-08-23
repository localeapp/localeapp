module Localeapp
  MissingTranslationRecord = Struct.new(:key, :locale, :options)

  class MissingTranslations
    def initialize
      @translations = Hash.new { |h, k| h[k] = {} }
    end

    def add(locale, key, options = {})
      record = MissingTranslationRecord.new(key, locale, options)
      @translations[locale][key] = record
    end

    def [](locale)
      @translations[locale]
    end

    # This method will get cleverer so we don't resend keys we've
    # already sent, or send multiple times for the same locale etc.
    # For now it's pretty dumb
    def to_send
      data = []
      # need the sort to make specs work under 1.8
      @translations.sort { |a, b| a.to_s <=> b.to_s }.each do |locale, records|
        records.each do |key, record|
          missing_data = {}
          missing_data[:key] = key
          missing_data[:locale] = locale
          missing_data[:options] = record.options
          data << missing_data
        end
      end
      data
    end
  end
end
