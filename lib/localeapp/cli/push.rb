module LocaleApp
  module CLI
    class Push
      include ::LocaleApp::ApiCall

      def initialize(output = $stdout)
        @output = output
      end

      def execute(file_path = nil)
        @output.puts "LocaleApp Push"
        @output.puts ""

        @file_path = file_path

        file = sanitize_file(file_path)
        if file
          @output.puts "Pushing file:"
          api_call :import,
            :payload => { :file => file },
            :success => :report_success,
            :failure => :report_failure,
            :max_connection_attempts => 3
        else
          @output.puts "Could not load file"
        end
      end

      def report_success(response)
        @output.puts "Success!"
        @output.puts ""
        @output.puts "#{@file_path} queued for processing."
      end

      def report_failure(response)
        @output.puts "Failed!"
      end

      private
      def sanitize_file(file_path)
        if File.exist?(file_path)
          File.new(file_path)
        else
          nil
        end
      end
    end
  end
end
