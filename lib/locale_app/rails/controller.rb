module LocaleApp
  module Rails
    module Controller
      def self.included(base)
        base.before_filter :handle_translation_updates
        base.after_filter  :send_missing_translations
      end

      def handle_translation_updates
        unless ::LocaleApp.configuration.polling_disabled?
          ::LocaleApp.log Time.now.to_i.to_s << '-- Handling translation updates'
          if ::LocaleApp.poller.needs_polling?
            ::LocaleApp.log Time.now.to_i.to_s << ' - polling'
            ::LocaleApp.poller.poll!
          end
        end

        unless ::LocaleApp.configuration.reloading_disabled?
          if ::LocaleApp.poller.needs_reloading?
            ::LocaleApp.log Time.now.to_i.to_s << '- reloading I18n'
            I18n.reload!
            ::LocaleApp.poller.updated_at = ::LocaleApp.poller.synchronization_data[:updated_at]
          end
        end
      end

      def send_missing_translations
        return if ::LocaleApp.configuration.sending_disabled?

        ::LocaleApp.sender.post_missing_translations
      end
    end
  end
end
