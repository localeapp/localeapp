module Localeapp
  module CLI
    class Update < Command
      attr_accessor :poller

      def execute
        self.poller = Localeapp::Poller.new
        if timestamp_too_old?
          @output.puts("Timestamp is missing or too old. Please run `localeapp pull` first.")
        else
          @output.puts("Localeapp update: checking for translations since #{poller.updated_at}")
          success = poller.poll!
          @output.puts(success ? "Found and updated new translations" : "No new translations")
        end
      end

    protected

      def timestamp_too_old?
        poller.updated_at < six_months_ago
      end

      def six_months_ago
        Time.now.to_i - 15552000 # This is 6.months.to_i according to ActiveRecord
      end
    end
  end
end
