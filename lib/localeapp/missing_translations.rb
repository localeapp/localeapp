module Localeapp
  MissingTranslationRecord = Struct.new(:key, :locale, :description, :options)

  class MissingTranslations
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
          missing_data[:description] = record.description if record.description
          missing_data[:options] = record.options
          data << missing_data
        end
      end
      data
    end
  end
end
