module ActionController
  class Base
    before_filter :handle_translation_updates

    def handle_translation_updates
      return if ::LocaleApp.configuration.polling_disabled?

      ::LocaleApp.log Time.now.to_i.to_s << '-- Handling translation updates'
      # ask the server for new translations
      if ::LocaleApp.poller.needs_polling?
        ::LocaleApp.log Time.now.to_i.to_s << ' - polling'
        if ::LocaleApp.poller.poll!
          ::LocaleApp.log Time.now.to_i.to_s << '- reloading I18n'
          I18n.reload!
          ::LocaleApp.poller.updated_at = ::LocaleApp.poller.synchronization_data[:updated_at]
        end
      end
    end
  end
end