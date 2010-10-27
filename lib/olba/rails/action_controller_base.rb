module ActionController
  class Base
    def handle_translation_updates

      # ask the server for new translations
      if ::Olba.receiver.needs_polling?
        ::Olba.receiver.poll!
        if ::Olba.receiver.cluster_updated?
          ::Olba.receiver.get_translations!
        end
      end
       
      # reload i18n when new translations have been downloaded
      if ::Olba.receiver.cluster_updated?
        I18n.reload!
        ::Olba.receiver.updated_at = ::Olba.receiver.cluster_log[:updated_at]
      end
    end
  end
end
