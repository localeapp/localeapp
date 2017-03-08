module Localeapp
  module CLI
    class Rename < Command
      include ::Localeapp::ApiCall

      def execute(current_name, new_name,  *rest)
        @output.puts "Localeapp mv"
        @output.puts ""
        @output.puts "Renaming key: #{current_name} to #{new_name}"
        api_call :rename,
          :url_options => { :current_name => current_name },
          :payload => { :new_name => new_name },
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
