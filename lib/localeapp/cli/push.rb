module Localeapp
  module CLI
    class Push < Command
      include ::Localeapp::ApiCall

      def execute(path = nil)
        @output.puts "Localeapp Push"
        if path_is_directory?(path)
          yaml_files_in_directory(path).each do |path|
            push_file(path)
          end
        else
          push_file(path)
        end
      end

      def push_file(file_path)
        @output.puts ""
        @file_path = file_path # for callbacks
        file = sanitize_file(file_path)
        if file
          @output.puts "Pushing file #{File.basename(file_path)}:"
          api_call :import,
            :payload => { :file => file },
            :success => :report_success,
            :failure => :report_failure,
            :max_connection_attempts => 1
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
        fail APIResponseError, "API returned #{response.code} status code"
      end

      private
      def sanitize_file(file_path)
        if File.exist?(file_path)
          File.new(file_path)
        else
          nil
        end
      end

      def path_is_directory?(path)
        File.directory?(path)
      end

      def yaml_files_in_directory(path)
        Dir.glob(File.join(path, '*.yml')).sort
      end
    end
  end
end
