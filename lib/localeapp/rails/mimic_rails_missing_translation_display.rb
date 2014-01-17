# Rails 3.2.16 and 4.0.2 introduced a new way of displaying missing translation :
# they now wrap them in a <span> element with useful class and title
#
# https://github.com/rails/rails/commit/78790e4bceedc632cb40f9597792d7e27234138a

module Localeapp
  module MimicRailsMissingTranslationDisplay
    def self.call(exception, locale, key, options)
      locale, key = super(exception, locale, key, options).split(', ')
      "<span class=\"translation_missing\" title=\"translation missing: #{key}\">#{locale}, #{key}</span>"
    end
  end
end

Localeapp::ExceptionHandler.send(:include, ::Localeapp::MimicRailsMissingTranslationDisplay)
