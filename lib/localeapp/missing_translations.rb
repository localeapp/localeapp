module Localeapp
  MissingTranslationRecord = Struct.new(:key, :locale, :description, :options)

  class MissingTranslations
    @cached_keys = []

    class << self
      attr_accessor :cached_keys
    end

    def initialize
      @translations = Hash.new { |h, k| h[k] = {} }
    end

    def add(locale, key, description = nil, options = {})
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
          next if cached?(key)
          cache(key)
          missing_data = {:key => key, :locale => locale, :options => record.options}
          missing_data[:description] = record.description if record.description
          data << missing_data
        end
      end
      data
    end

    private

    def cached_keys
      self.class.cached_keys
    end

    def cached?(key)
      Localeapp.configuration.cache_missing_translations && cached_keys.include?(key)
    end

    def cache(key)
      cached_keys << key if Localeapp.configuration.cache_missing_translations
    end
  end
end
