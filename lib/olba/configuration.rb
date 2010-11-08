module LocaleApp
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

    # The path to the project in which the translation occurred, such as the RAILS_ROOT 
    attr_accessor :project_root

    # The names of environments where notifications aren't sent (defaults to 'test', 'cucumber')
    attr_accessor :development_environments

    # The logger used by LocaleApp
    attr_accessor :logger

    # The number of seconds to wait before asking the service for new translations (defaults to 60).
    attr_accessor :poll_interval

    # The complete path to the log file where we store clustier information (defaults to ./olba.yml)
    # olb/rails overwrites this to RAILS_ROOT/config/olba.yml
    attr_accessor :cluster_log

    # The complete path to the file where translations are stored
    attr_accessor :locale_file

    def initialize
      @host                     = 'hablo.co'
      @port                     = 80
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @development_environments = %w(test cucumber)
      @poll_interval            = 60
      @cluster_log              = 'olba.yml'
      @locale_file              = 'translations.yml'
    end
  end
end
