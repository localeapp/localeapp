module Localeapp
  module CLI
    class Get < Command
      include ::Localeapp::ApiCall

      def execute(locale_key, translations)
        @translations = translations
        @locale_key = locale_key

        @output.puts "Localeapp Get\n\n"
        translations.each do |translation|
          @output.puts "Fetching#{locale_key ? ' ' << locale_key : ''} #{translation} translations:"
        end

        api_call :export,
          :success => :update_backend,
          :failure => :report_failure,
          :max_connection_attempts => 1
      end

      def update_backend(response)
        @output.puts "Success!"
        @output.puts "Updating backend:"
        Localeapp.updater.dump_translation_keys(Localeapp.yaml_data(response, @locale_key), @translations)
        @output.puts "Success!"
        Localeapp.poller.write_synchronization_data!(Time.now.to_i, Time.now.to_i)
      end

      def report_failure(response)
        @output.puts "Failed!"
        fail APIResponseError, "API returned #{response.code} status code"
      end
    end
  end
end
