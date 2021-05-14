module Localeapp
  module CLI
    class Remove < Command
      include ::Localeapp::ApiCall

      def execute(key, *rest)
        @output.puts "Localeapp rm"
        @output.puts ""
        @output.puts "Remove key: #{key}"
        # monkey path this method in our own projects
        # or maybe suggest it for PR instead
        # add a confirmation before actually delete the key
        STDOUT.puts "Are you sure? Enter 'yes' to confirm:"
        input = STDIN.gets.chomp
        raise "Aborting removing key: #{key}. You entered #{input}" unless input == 'yes'
        api_call :remove,
          :url_options => { :key => key },
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
