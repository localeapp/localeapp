module I18n::Backend::Base
  alias_method :default_without_handler, :default

  def default(locale, object, subject, options = {})
    result = default_without_handler(locale, object, subject, options)
    Localeapp.missing_translations.add(locale, object, subject, options)
    return result
  end
end
