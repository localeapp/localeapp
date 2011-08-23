require 'yaml'
require 'rest-client'
require 'time'

module Localeapp
  class KeyChecker
    include ::Localeapp::ApiCall

    def check(key)
      if Localeapp.configuration.nil? # no config file yet
        Localeapp.configuration = Localeapp::Configuration.new
        Localeapp.configuration.host = ENV['LA_TEST_HOST'] if ENV['LA_TEST_HOST']
      end
      Localeapp.configuration.api_key = key
      api_call :project,
        :success => :handle_success,
        :failure => :handle_failure,
        :max_connection_attempts => 1

      if @checked
        [@ok, @data]
      else
        [false, "Error communicating with server"]
      end
    end

    def handle_success(response)
      @checked = true
      @ok = true
      @data = JSON.parse(response)
    end

    def handle_failure(response)
      if response.code.to_i == 404
        @checked = true
        @ok = false
        @data = {}
      else
        @checked = false
      end
    end
  end
end
