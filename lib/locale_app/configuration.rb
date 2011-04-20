module LocaleApp
  class Configuration
  
    # The API key for your project, found on the project edit form
    attr_accessor :api_key

    # The host to connect to (defaults to hablo.co)
    attr_accessor :host

    # The port to connect to (defaults to 80)
    attr_accessor :port

    attr_accessor :http_auth_username
    attr_accessor :http_auth_password

    # The name of the environment the application is running in
    attr_accessor :environment_name

    # The path to the project in which the translation occurred, such as the
    # RAILS_ROOT
    attr_accessor :project_root

    # The names of environments where notifications aren't sent (defaults to
    # 'test', 'cucumber')
    attr_accessor :disabled_environments

    # The logger used by LocaleApp
    attr_accessor :logger

    # The number of seconds to wait before asking the service for new
    # translations (defaults to 60).
    attr_accessor :poll_interval

    # The complete path to the data file where we store synchronization
    # information (defaults to ./locale_app.yml) local_app/rails overwrites
    # this to RAILS_ROOT/log/locale_app.yml
    attr_accessor :synchronization_data_file

    # The complete path to the directory where translations are stored
    attr_accessor :translation_data_directory

    def initialize
      @host                       = 'api.localeapp.com'
      @port                       = 80
      @disabled_environments      = %w(test cucumber)
      @poll_interval              = 60
      @synchronization_data_file  = 'locale_app.yml'
      @translation_data_directory = File.join('config', 'locales')
    end

    def disabled?
      disabled_environments.include?(environment_name)
    end

    def write_initial(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.open(path, 'w+') do |file|
        file.write <<-CONTENT
require 'locale_app/rails'

LocaleApp.configure do |config|
  config.api_key = '#{@api_key}'
end
CONTENT
      end
    end
  end
end
