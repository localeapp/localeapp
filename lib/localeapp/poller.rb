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
      @polled_at  = synchronization_data[:polled_at]
      @updated_at = synchronization_data[:updated_at]
    end

    def synchronization_data
      if File.exist?(Localeapp.configuration.synchronization_data_file)
        Localeapp.load_yaml_file(Localeapp.configuration.synchronization_data_file) ||
        default_synchronization_data
      else
        default_synchronization_data
      end
    end

    def write_synchronization_data!(polled_at, updated_at)
      File.open(Localeapp.configuration.synchronization_data_file, 'w+') do |f|
        f.write({:polled_at => polled_at.to_i, :updated_at => updated_at.to_i}.to_yaml)
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
      Localeapp.log_with_time "poll success"
      @success = true
      Localeapp.updater.update(Localeapp.load_yaml(response))
      write_synchronization_data!(current_time, Time.parse(response.headers[:date]))
    end

    def handle_failure(response)
      if response.code == 304
        Localeapp.log_with_time "No new data"
        # Nothing new, update synchronization files
        write_synchronization_data!(current_time, updated_at)
      end
      @success = false
    end

    private
    def current_time
      Time.now
    end

    def default_synchronization_data
      {:polled_at => 0, :updated_at => 0}
    end
  end
end
