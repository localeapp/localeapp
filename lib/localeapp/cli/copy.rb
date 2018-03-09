module Localeapp
  module CLI
    class Copy < Command
      include ::Localeapp::ApiCall

      def execute(source_name, dest_name, *rest)
        @output.puts "Localeapp cp"
        @output.puts ""
        @output.puts "Copying key: #{source_name} to #{dest_name}"
        api_call :copy,
          :url_options => { :source_name => source_name },
          :payload => { :dest_name => dest_name },
          :success => :report_success,
          :failure => :report_failure,
          :max_connection_attempts => 1
      end

      def report_success(response)
        @output.puts "Success!"
      end

      def report_failure(response)
        @output.puts "Failed!"
        fail APIResponseError, "API returned #{response.code} status code"
      end
    end
  end
end
