module ActionController
  class Base
    def handle_translation_updates
      ::LocaleApp.log Time.now.to_i.to_s << '-- Handling translation updates'
      # ask the server for new translations
      if ::LocaleApp.poller.needs_polling?
        ::LocaleApp.log Time.now.to_i.to_s << ' - polling'
        ::LocaleApp.poller.poll!
        if ::LocaleApp.poller.cluster_updated?
          ::LocaleApp.log Time.now.to_i.to_s << '- downloading translations'
          ::LocaleApp.poller.get_translations!
        end
      end
       
      # reload i18n when new translations have been downloaded
      if ::LocaleApp.poller.cluster_updated?
        ::LocaleApp.log Time.now.to_i.to_s << '- reloading I18n'
        I18n.reload!
        ::LocaleApp.poller.updated_at = ::LocaleApp.poller.synchronization_data[:updated_at]
      end
    end
  end
end
