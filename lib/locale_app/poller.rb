require 'yaml'
require 'rest-client'
require 'time'

module LocaleApp
  class Poller
    include ::LocaleApp::ApiCall
    
    # when we last asked the service for updates
    attr_accessor :polled_at

    # the last time the service had updates for us
    attr_accessor :updated_at

    def initialize
      @polled_at  = synchronization_data[:polled_at]
      @updated_at = synchronization_data[:updated_at]
    end

    def synchronization_data
      if File.exists?(LocaleApp.configuration.synchronization_data_file)
        YAML.load_file(LocaleApp.configuration.synchronization_data_file)
      else
        {}
      end
    end

    def write_synchronization_data!(polled_at, updated_at)
      File.open(LocaleApp.configuration.synchronization_data_file, 'w+') do |f|
        f.write({:polled_at => polled_at, :updated_at => updated_at}.to_yaml)
      end
    end

    def needs_polling?
      synchronization_data[:polled_at] < (Time.now.to_i - LocaleApp.configuration.poll_interval)
    end

    def poll!
      polled_at = Time.now.to_i # don't care about split second timing here
      @updated_at = synchronization_data[:updated_at]

      api_call :translations,
        :url_options => { :query => { :updated_at => updated_at }},
        :success => :handle_success,
        :failure => :handle_failure,
        :max_connection_attempts => 1

      write_synchronization_data!(polled_at, @updated_at)
      @success
    end

    def handle_success(response)
      @success = true
      @updated_at = Time.parse(response.headers[:date]).to_i
      LocaleApp.updater.update(JSON.parse(response))
    end

    def handle_failure(response)
      @success = false
    end
  end
end
