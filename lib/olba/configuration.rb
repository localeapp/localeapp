module Olba
  class Configuration
  
    # The API key for your project, found on the project edit form
    attr_accessor :api_key

    # The host to connect to (defaults to hablo.co)
    attr_accessor :host

    # The port to connect to (defaults to 80)
    attr_accessor :port

    # The HTTP open timeout in seconds (defaults to 2).
    attr_accessor :http_open_timeout

    # The HTTP read timeout in seconds (defaults to 5).
    attr_accessor :http_read_timeout

    # The name of the environment the application is running in
    attr_accessor :environment_name

    # The names of environments where notifications aren't sent (defaults to 'test', 'cucumber')
    attr_accessor :development_environments

    # The logger used by Olba
    attr_accessor :logger

    def initialize
      @host                     = 'hablo.co'
      @port                     = 80
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @development_environments = %w(test cucumber)
    end

    # Determines if the notifier will send notices.
    # @return [Boolean] Returns +false+ if in a development environment, +true+ otherwise.
    def public?
      !development_environments.include?(environment_name)
    end
  end
end
