# Rails 3.2.16 and 4.0.2 introduced a fix for CVE-2013-4491 :
# https://github.com/rails/rails/commit/78790e4bceedc632cb40f9597792d7e27234138a
#
# This fix introduces a :raise option to the :translate helper, which
# defines wether an exception shall be raised (:raise => true) or delegated
# to I18n.exception_handler (:raise => false).
#
# This monkey patch forces :raise to `false`, to force use of Localeapp::ExceptionHandler
#
# NB: the CVE-2013-4491 fix also introduced a regression which is fixed in:
#     https://github.com/rails/rails/commit/31a485fa5a843a766c4b889ee88a6c590a3a6ebb


module Localeapp
  module ForceExceptionHandlerInTranslationHelper
    def translate(key, options = {})
      super(key, {:raise => false}.merge(options))
    end
    alias :t :translate
  end
end

ActionView::Base.send(:include, ::Localeapp::ForceExceptionHandlerInTranslationHelper)
