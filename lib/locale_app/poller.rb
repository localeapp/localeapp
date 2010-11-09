require 'yaml'
require 'rest-client'

module LocaleApp
  class Poller
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

    def translations_changed?
      @updated_at != synchronization_data[:updated_at]
    end

    def needs_polling?
      synchronization_data[:polled_at] < (Time.now.to_i - LocaleApp.configuration.poll_interval)
    end

    def poll!
      RestClient.get(translation_resource_status_url) do |response, request, result|
        if response.code == 200
          remote_updated_at = Time.parse(response.to_str).to_i
        else
          remote_updated_at = synchronization_data[:updated_at]
        end
        File.open(LocaleApp.configuration.synchronization_data_file, 'w') do |f|
          f.write({:polled_at => Time.now.to_i, :updated_at => remote_updated_at}.to_yaml)
        end
      end
      # get updated_at from server
    end

    def get_translations!
      RestClient.get(translation_resource_url) do |response, request, result|
        LocaleApp.log([translation_resource_url, response.code].join(' - '))
        if response.code == 200
          File.open(LocaleApp.configuration.translation_data_file, 'w') do |f|
            f.write(response.to_str)
          end
        end
      end
    end

    def translation_resource_url
      "http://#{LocaleApp.configuration.host}:#{LocaleApp.configuration.port}/translations.yml?api_key=#{LocaleApp.configuration.api_key}"
    end

    def translation_resource_status_url
      puts "http://#{LocaleApp.configuration.host}:#{LocaleApp.configuration.port}/translations/updated_at?api_key=#{LocaleApp.configuration.api_key}"
      "http://#{LocaleApp.configuration.host}:#{LocaleApp.configuration.port}/translations/updated_at?api_key=#{LocaleApp.configuration.api_key}"
    end
  end
end
