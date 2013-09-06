module I18n::Backend::Base
  alias_method :default_without_handler, :default

  def default(locale, object, subject, options = {})
    result = default_without_handler(locale, object, subject, options)

    original_object = object
    object ||= Thread.current[:i18n_default_object]
    case subject # case is what i18n gem uses here so doing the same
    when String
      value = locale.to_s == I18n.default_locale.to_s ? subject : nil
      Localeapp.missing_translations.add(locale, object, value, options)
    when Array
      text_default = subject.detect{|item| item.is_a? String }
      if text_default
        value = locale.to_s == I18n.default_locale.to_s ? text_default : nil
        Localeapp.missing_translations.add(locale, object, value, options)
      end
    when Symbol
      # Do nothing, we only send missing translations with text defaults
    end

    # Remember the object because it will be nil after the fallback
    Thread.current[:i18n_default_object] = original_object
    return result
  end
end
