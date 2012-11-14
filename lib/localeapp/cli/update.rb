module Localeapp
  module CLI
    class Update < Command
      def execute
        poller = Localeapp::Poller.new
        @output.puts("Localeapp update: checking for translations since #{poller.updated_at}")
        if poller.poll!
          @output.puts "Found and updated new translations"
        else
          @output.puts "No new translations"
        end
      end
    end
  end
end
