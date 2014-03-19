module Localeapp
  class ApiCaller
    include ::Localeapp::Routes

    NonHTTPResponse = Struct.new(:code)

    DEFAULT_RETRY_LIMIT = 1

    # we can retry more in the gem than we can
    # when running in process
    attr_accessor :max_connection_attempts

    attr_reader :endpoint, :options, :connection_attempts

    def initialize(endpoint, options = {})
      @endpoint, @options = endpoint, options
      @connection_attempts = 0
      @max_connection_attempts = options[:max_connection_attempts] || DEFAULT_RETRY_LIMIT
    end

    def call(obj)
      method, url = send("#{endpoint}_endpoint", options[:url_options] || {})
      Localeapp.debug("API CALL: #{method} #{url}")
      success = false
      while connection_attempts < max_connection_attempts
        sleep_if_retrying

        response = make_call(method, url)
        Localeapp.debug("RESPONSE: #{response.code}")

        fix_encoding(response)

        valid_response_codes = (200..207).to_a
        if valid_response_codes.include?(response.code.to_i)
          if options[:success]
            Localeapp.debug("CALLING SUCCESS HANDLER: #{options[:success]}")
            obj.send(options[:success], response)
          end
          success = true
          break
        end
      end

      if !success && options[:failure]
        obj.send(options[:failure], response)
      end
    end

    private
    def make_call(method, url)
      begin
        @connection_attempts += 1
        Localeapp.debug("ATTEMPT #{@connection_attempts}")
        headers = { :x_localeapp_gem_version => Localeapp::VERSION }.merge(options[:headers] || {})
        parameters = {
          :url => url,
          :method => method,
          :headers => headers,
          :timeout => Localeapp.configuration.timeout,
          :verify_ssl => (Localeapp.configuration.ssl_verify ? OpenSSL::SSL::VERIFY_PEER : false)
        }
        parameters[:ca_file] = Localeapp.configuration.ssl_ca_file if Localeapp.configuration.ssl_ca_file
        if method == :post
          parameters[:payload] = options[:payload]
        end
        RestClient.proxy = Localeapp.configuration.proxy if Localeapp.configuration.proxy
        RestClient::Request.execute(parameters)
      rescue RestClient::ResourceNotFound,
        RestClient::NotModified,
        RestClient::InternalServerError,
        RestClient::BadGateway,
        RestClient::ServiceUnavailable,
        RestClient::UnprocessableEntity,
        RestClient::GatewayTimeout => error
        return error.response
      rescue RestClient::ServerBrokeConnection => error
        return NonHTTPResponse.new(-1)
      rescue Errno::ECONNREFUSED => error
        Localeapp.debug("ERROR: Connection Refused")
        return NonHTTPResponse.new(-1)
      rescue SocketError => error
        Localeapp.debug("ERROR: Socket Error #{error.message}")
        return NonHTTPResponse.new(-1)
      end
    end

    def sleep_if_retrying
      if @connection_attempts > 0
        time = @connection_attempts * 5
        Localeapp.debug("Sleeping for #{time} before retrying")
        sleep time
      end
    end

    def fix_encoding(response)
      if response.respond_to?(:force_encoding)
        if (charset = response.net_http_res.type_params['charset'])
          response.force_encoding(charset)
        end
      end
    end
  end
end
