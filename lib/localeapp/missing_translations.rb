module Localeapp
  MissingTranslationRecord = Struct.new(:key, :locale, :description, :options) do
    def blacklisted?
      key_path.match(Localeapp.configuration.blacklisted_keys_pattern)
    end

    def key_path
      [options[:scope], key].compact.join('.')
    end
  end

  class MissingTranslations
    @cached_keys = []

    class << self
      attr_accessor :cached_keys
    end

    def initialize
      @translations = Hash.new { |h, k| h[k] = {} }
    end

    def add(locale, key, description = nil, options = {})
      separator = options.delete(:separator) { I18n.default_separator }
      scope = options.delete(:scope)
      key = I18n.normalize_keys(nil, key, scope, separator).map(&:to_s).join(separator)
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

    def reject_blacklisted
      return unless Localeapp.configuration.blacklisted_keys_pattern
      @translations.each do |locale, records|
        records.reject! { |key, record| record.blacklisted? }
      end
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
