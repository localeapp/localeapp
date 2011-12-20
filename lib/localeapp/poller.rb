require 'yaml'
require 'rest-client'
require 'time'

module Localeapp
  class Poller
    include ::Localeapp::ApiCall
    
    # when we last asked the service for updates
    attr_accessor :polled_at

    # the last time the service had updates for us
    attr_accessor :updated_at

    def initialize
      @polled_at  = synchronization_data[:polled_at]  || 0
      @updated_at = synchronization_data[:updated_at] || 0
    end

    def synchronization_data
      if File.exists?(Localeapp.configuration.synchronization_data_file)
        YAML.load_file(Localeapp.configuration.synchronization_data_file) || {}
      else
        {}
      end
    end

    def write_synchronization_data!(polled_at, updated_at)
      File.open(Localeapp.configuration.synchronization_data_file, 'w+') do |f|
        f.write({:polled_at => polled_at, :updated_at => updated_at}.to_yaml)
      end
    end

    def needs_polling?
      synchronization_data[:polled_at] < (Time.now.to_i - Localeapp.configuration.poll_interval)
    end

    def needs_reloading?
      synchronization_data[:updated_at] != @updated_at
    end

    def poll!
      api_call :translations,
        :url_options => { :query => { :updated_at => updated_at }},
        :success => :handle_success,
        :failure => :handle_failure,
        :max_connection_attempts => 1
      @success
    end

    def handle_success(response)
      @success = true
      Localeapp.updater.update(YAML.load(response))
      write_synchronization_data!(Time.now.to_i, Time.parse(response.headers[:date]).to_i)
    end

    def handle_failure(response)
      @success = false
    end
  end
end
