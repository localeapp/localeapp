# We're replacing the original method with one that doesn't set the :raise option.
# This means the exception handler will be called and missing translations get sent to
# localeapp. It's ugly but there's no other way to do it :(

module ActionView
  module Helpers
    module TranslationHelper
      # Delegates to I18n#translate but also performs two additional functions. First, it'll catch MissingTranslationData exceptions
      # and turn them into inline spans that contains the missing key, such that you can see in a view what is missing where.
      #
      # Second, it'll scope the key by the current partial if the key starts with a period. So if you call translate(".foo") from the
      # people/index.html.erb template, you'll actually be calling I18n.translate("people.index.foo"). This makes it less repetitive
      # to translate many keys within the same partials and gives you a simple framework for scoping them consistently. If you don't
      # prepend the key with a period, nothing is converted.
      def translate(keys, options = {})
        if multiple_keys = keys.is_a?(Array)
          ActiveSupport::Deprecation.warn "Giving an array to translate is deprecated, please give a symbol or a string instead", caller
        end

        keys = scope_keys_by_partial(keys)

        translations = I18n.translate(keys, options)
        translations = [translations] if !multiple_keys && translations.size > 1
        translations = html_safe_translation_keys(keys, translations)

        if multiple_keys || translations.size > 1
          translations
        else
          translations.first
        end
      rescue I18n::MissingTranslationData => e
        keys = I18n.send(:normalize_translation_keys, e.locale, e.key, e.options[:scope])
        content_tag('span', keys.join(', '), :class => 'translation_missing')
      end
    end
  end
end
