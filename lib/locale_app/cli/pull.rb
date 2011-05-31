module LocaleApp
  module CLI
    class Pull
      include ::LocaleApp::ApiCall

      def initialize(output = $stdout)
        @output = output
      end

      def execute
        @output.puts "LocaleApp Pull"
        @output.puts ""

        @output.puts "Fetching translations:"
        api_call :translations,
          :success => :update_backend,
          :failure => :report_failure,
          :max_connection_attempts => 3
      end

      def update_backend(response)
        @output.puts "Success!"
        @output.puts "Updating backend:"
        LocaleApp.updater.update(JSON.parse(response))
        @output.puts "Success!"
        LocaleApp.poller.write_synchronization_data!(Time.now.to_i, Time.now.to_i)
      end
    end
  end
end
