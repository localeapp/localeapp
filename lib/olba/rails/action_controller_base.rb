module ActionController
  class Base
    def handle_translation_updates
      puts Time.now.to_i.to_s << '-- Handling translation updates'
      # ask the server for new translations
      if ::LocaleApp.receiver.needs_polling?
        puts Time.now.to_i.to_s << ' - polling'
        ::LocaleApp.receiver.poll!
        if ::LocaleApp.receiver.cluster_updated?
          puts Time.now.to_i.to_s << '- downloading translations'
          ::LocaleApp.receiver.get_translations!
        end
      end
       
      # reload i18n when new translations have been downloaded
      if ::LocaleApp.receiver.cluster_updated?
        puts Time.now.to_i.to_s << '- reloading I18n'
        I18n.reload!
        ::LocaleApp.receiver.updated_at = ::LocaleApp.receiver.cluster_log[:updated_at]
      end
    end
  end
end
