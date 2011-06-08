module LocaleApp
  module CLI
    class Update
      def initialize(output = $stdout)
        @output = output
      end

      def execute
        poller = LocaleApp::Poller.new
        @output.puts("LocaleApp update: checking for translations since #{poller.updated_at}")
        if poller.poll!
          @output.puts "Found and updated new translations"
        end
      end
    end
  end
end
