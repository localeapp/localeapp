module Localeapp
  module Routes

  private

    def http_scheme
      if Localeapp.configuration.secure
        URI::HTTPS
      else
        URI::HTTP
      end
    end

    def base_options
      options = {:host => Localeapp.configuration.host, :port => Localeapp.configuration.port}
      if Localeapp.configuration.http_auth_username
        options[:userinfo] = "#{Localeapp.configuration.http_auth_username}:#{Localeapp.configuration.http_auth_password}"
      end
      options
    end

    def escape_key(key)
      Rack::Utils.escape(key).gsub(/\./, '%2E')
    end
  end
end
