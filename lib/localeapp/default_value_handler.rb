module I18n::Backend::Base
  alias_method :default_without_handler, :default

  def default(locale, object, subject, options = {})
    result = default_without_handler(locale, object, subject, options)
    case subject # case is what i18n gem uses here so doing the same
    when Array
      # Do nothing, we only send missing translations with text defaults
    else
      value = locale == I18n.default_locale ? subject : nil
      Localeapp.missing_translations.add(locale, object, value, options)
    end
    return result
  end
end
