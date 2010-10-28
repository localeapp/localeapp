module ActionController
  class Base
    def handle_translation_updates
      puts Time.now.to_i.to_s << '-- Handling translation updates'
      # ask the server for new translations
      if ::Olba.receiver.needs_polling?
        puts Time.now.to_i.to_s << ' - polling'
        ::Olba.receiver.poll!
        if ::Olba.receiver.cluster_updated?
          puts Time.now.to_i.to_s << '- downloading translations'
          ::Olba.receiver.get_translations!
        end
      end
       
      # reload i18n when new translations have been downloaded
      if ::Olba.receiver.cluster_updated?
        puts Time.now.to_i.to_s << '- reloading I18n'
        I18n.reload!
        ::Olba.receiver.updated_at = ::Olba.receiver.cluster_log[:updated_at]
      end
    end
  end
end
