require 'yaml'
require 'rest-client'
require 'time'

module LocaleApp
  class Poller
    include ::LocaleApp::Routes
    
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

    def needs_polling?
      synchronization_data[:polled_at] < (Time.now.to_i - LocaleApp.configuration.poll_interval)
    end

    def poll!
      polled_at = Time.now.to_i # don't care about split second timing here
      updated_at = synchronization_data[:updated_at]
      did_update = begin
        response = RestClient.get(translations_url(:query => {:updated_at => updated_at}), :accept => :json)
        if response.code == 200
          updated_at = Time.parse(response.headers[:date]).to_i
          Updater.update(JSON.parse(response))
          true
        else
          false
        end
      rescue RestClient::RequestFailed, RestClient::NotModified
        false
      end
      File.open(LocaleApp.configuration.synchronization_data_file, 'w+') do |f|
        f.write({:polled_at => polled_at, :updated_at => updated_at}.to_yaml)
      end

      did_update
    end

  end
end
