module Localeapp
  class Configuration
  
    # The API key for your project, found on the project edit form
    attr_accessor :api_key

    # The host to connect to (defaults to api.localeapp.com)
    attr_accessor :host

    # The proxy to connect via
    attr_accessor :proxy

    # Whether to use https or not (defaults to true)
    attr_accessor :secure

    # Whether to verify ssl server certificates or not (defaults to false, see README)
    attr_accessor :ssl_verify

    # Path to local CA certs bundle
    attr_accessor :ssl_ca_file

    # The port to connect to if it's not the default one
    attr_accessor :port

    attr_accessor :http_auth_username
    attr_accessor :http_auth_password

    # The name of the environment the application is running in
    attr_accessor :environment_name

    # The path to the project in which the translation occurred, such as the
    # RAILS_ROOT
    attr_accessor :project_root

    # The names of environments where notifications are sent
    # (defaults to 'development')
    attr_accessor :sending_environments

    # The names of environments where I18n.reload is called for each request
    # (defaults to 'development')
    attr_accessor :reloading_environments

    # The names of environments where updates aren't pulled
    # (defaults to 'development')
    attr_accessor :polling_environments

    # @deprecated Use {#sending_environments} instead. This is safer but make sure to reverse your logic if you've changed the defaults
    # The names of environments where notifications aren't sent (defaults to
    # 'test', 'cucumber', 'production')
    attr_accessor :disabled_sending_environments
    def disabled_sending_environments=(value)
      @deprecated_environment_config_used = true
      @disabled_sending_environments = value
    end

    # @deprecated Use {#reloading_environments} instead. This is safer but make sure to reverse your logic if you've changed the defaults
    # The names of environments where I18n.reload isn't called for each request
    # (defaults to 'test', 'cucumber', 'production')
    attr_accessor :disabled_reloading_environments
    def disabled_reloading_environments=(value)
      @deprecated_environment_config_used = true
      @disabled_reloading_environments = value
    end

    # @deprecated Use {#polling_environments} instead. This is safer but make sure to reverse your logic if you've changed the defaults
    # The names of environments where updates aren't pulled (defaults to
    # 'test', 'cucumber', 'production')
    attr_accessor :disabled_polling_environments
    def disabled_polling_environments=(value)
      @deprecated_environment_config_used = true
      @disabled_polling_environments = value
    end

    # The logger used by Localeapp
    attr_accessor :logger

    # The number of seconds to wait before asking the service for new
    # translations (defaults to 0 - every request).
    attr_accessor :poll_interval

    # The complete path to the data file where we store synchronization
    # information (defaults to ./localeapp.yml) local_app/rails overwrites
    # this to RAILS_ROOT/log/localeapp.yml
    attr_accessor :synchronization_data_file

    # The complete path to the directory where translations are stored
    attr_accessor :translation_data_directory

    # The directory where localeapp.pid is stored
    attr_accessor :pids_directory

    def deprecated_environment_config_used?
      @deprecated_environment_config_used
    end

    def initialize
      @host                            = 'api.localeapp.com'
      @secure                          = true
      @ssl_verify                      = false
      @disabled_sending_environments   = %w(test cucumber production)
      @disabled_reloading_environments = %w(test cucumber production)
      @disabled_polling_environments   = %w(test cucumber production)
      @sending_environments            = %w(development)
      @reloading_environments          = %w(development)
      @polling_environments            = %w(development)
      @poll_interval                   = 0
      @synchronization_data_file       = File.join('log', 'localeapp.yml')
      @translation_data_directory      = File.join('config', 'locales')
      @pids_directory                  = File.join('tmp', 'pids')
      if ENV['DEBUG']
        require 'logger'
        @logger = Logger.new(STDOUT)
      end
    end

    def polling_disabled?
      if deprecated_environment_config_used?
        ::Localeapp.log "DEPRECATION: disabled_polling_environments is deprecated and will be removed. Use polling_environments instead and reverse the logic if you've changed the defaults"
        disabled_polling_environments.map { |v| v.to_s }.include?(environment_name)
      else
        !polling_environments.map { |v| v.to_s }.include?(environment_name)
      end
    end

    def reloading_disabled?
      if deprecated_environment_config_used?
        ::Localeapp.log "DEPRECATION: disabled_reloading_environments is deprecated and will be removed. Use reloading_environments instead and reverse the logic if you've changed the defaults"
        disabled_reloading_environments.map { |v| v.to_s }.include?(environment_name)
      else
        !reloading_environments.map { |v| v.to_s }.include?(environment_name)
      end
    end

    def sending_disabled?
      if deprecated_environment_config_used?
        ::Localeapp.log "DEPRECATION: disabled_sending_environments is deprecated and will be removed. Use sending_environments instead and reverse the logic if you've changed the defaults"
        disabled_sending_environments.map { |v| v.to_s }.include?(environment_name)
      else
        !sending_environments.map { |v| v.to_s }.include?(environment_name)
      end
    end

    def write_rails_configuration(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.open(path, 'w+') do |file|
        file.write <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = '#{@api_key}'
end
CONTENT
      end
    end

    def write_dot_file_configuration(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.open(path, 'w+') do |file|
        file.write <<-CONTENT
Localeapp.configure do |config|
  config.api_key                    = '#{@api_key}'
  config.translation_data_directory = 'locales'
  config.synchronization_data_file  = '.localeapp/log.yml'
  config.pids_directory             = '.localeapp'
end
CONTENT
      end
    end

  end
end
