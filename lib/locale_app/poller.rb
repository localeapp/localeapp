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

    def needs_polling?
      synchronization_data[:polled_at] < (Time.now.to_i - LocaleApp.configuration.poll_interval)
    end

    def poll!
      response = RestClient.get(translation_resource_url)
      polled_at = Time.now.to_i # don't care about split second timing here
      updated_at = synchronization_data[:updated_at]
      did_update = case response.code
      when 304; false
      when 500..599; false
      when 200
        updated_at = response.headers[:date].to_i
        Updater.update(JSON.parse(response))
        true
      else false
      end
      File.open(LocaleApp.configuration.synchronization_data_file, 'w+') do |f|
        f.write({:polled_at => polled_at, :updated_at => updated_at}.to_yaml)
      end

      did_update
    end

    def translation_resource_url
      uri_params = {
        :host => LocaleApp.configuration.host,
        :port => LocaleApp.configuration.port,
        :path => '/translations.json',
        :query => "api_key=#{LocaleApp.configuration.api_key}&updated_at=#{synchronization_data[:updated_at]}"
      }
      if LocaleApp.configuration.http_auth_username
        uri_params[:userinfo] = "#{LocaleApp.configuration.http_auth_username}:#{LocaleApp.configuration.http_auth_password}"
      end
      URI::HTTP.build(uri_params).to_s
    end
  end
end
