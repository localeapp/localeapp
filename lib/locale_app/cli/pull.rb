module LocaleApp
  module CLI
    class Pull
      DEFAULT_RETRY_LIMIT = 1
      include ::LocaleApp::Routes

      attr_reader :connection_attempts

      # we can retry more in the gem than we can
      # when running in process
      attr_accessor :max_connection_attempts

      def initialize
        @connection_attempts = 0
        @max_connection_attempts = DEFAULT_RETRY_LIMIT
      end

      def execute(output = $stdout)
        output.puts "LocaleApp Pull"
        output.puts ""

        output.puts "Fetching translations:"
        while connection_attempts < max_connection_attempts do
          sleep_if_retrying
          response = fetch_translations
          case response.code
          when 200
            puts "Success!"
            puts "Updating backend:"
            LocaleApp.updater.update(JSON.parse(response))
            puts "Success!"
            LocaleApp.poller.write_synchronization_data!(Time.now.to_i, Time.now.to_i)
            break
          end
        end
      end

      private
      def fetch_translations
        begin
          @connection_attempts += 1
          RestClient.get(translations_url)
        rescue RestClient::InternalServerError,
               RestClient::BadGateway,
               RestClient::ServiceUnavailable,
               RestClient::GatewayTimeout => error
          return error.response
        end
      end

      # Back off a bit more 5 each retry
      def sleep_if_retrying
        if @connection_attempts > 0
          sleep @connection_attempts * 5
        end
      end
    end
  end
end
