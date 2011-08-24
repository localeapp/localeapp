module I18n
  class MissingTranslation
    attr_reader :locale, :key, :options

    def initialize(locale, key, options = nil)
      @key, @locale, @options = key, locale, options.dup || {}
      options.each { |k, v| self.options[k] = v.inspect if v.is_a?(Proc) }
    end

    def keys
      @keys ||= I18n.normalize_keys(locale, key, options[:scope]).tap do |keys|
        keys << 'no key' if keys.size < 2
      end
    end

    def message
      "translation missing: #{keys.join('.')}"
    end
    alias :to_s :message

  end
end
