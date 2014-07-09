module Localeapp
  class Configuration

    # The API key for your project, found on the project edit form
    attr_accessor :api_key

    # The host to connect to (defaults to api.localeapp.com)
    attr_accessor :host

    # The proxy to connect via
    attr_accessor :proxy

    # The request timeout
    attr_accessor :timeout

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

    # The logger used by Localeapp
    attr_accessor :logger

    # The number of seconds to wait before asking the service for new
    # translations (defaults to 0 - every request).
    attr_accessor :poll_interval

    # The complete path to the data file where we store synchronization
    # information (defaults to ./localeapp.yml) local_app/rails overwrites
    # this to RAILS_ROOT/log/localeapp.yml
    attr_accessor :synchronization_data_file

    # The complete path to the pid file where we store information about daemon
    # default: RAILS_ROOT/tmp/pids/localeapp.pid
    attr_accessor :daemon_pid_file

    # The complete path to the log file where we store information about daemon actions
    # default: RAILS_ROOT/log/localeapp_daemon.log
    attr_accessor :daemon_log_file

    # The complete path to the directory where translations are stored
    attr_accessor :translation_data_directory

    # Enable or disable the insecure yaml exception
    # default: true
    attr_accessor :raise_on_insecure_yaml

    # Enable or disable the missing translation cache
    # default: false
    attr_accessor :cache_missing_translations
    
    # A regular expression that is matched against a translation key.
    # If the key matches, the translation will not be sent to the Locale
    # server via the rails exception handler.
    # default: nil
    attr_accessor :blacklisted_keys_pattern

    def initialize
      defaults.each do |setting, value|
        send("#{setting}=", value)
      end
    end

    def defaults
      defaults = {
        :host                       => 'api.localeapp.com',
        :timeout                    => 60,
        :secure                     => true,
        :ssl_verify                 => false,
        :sending_environments       => %w(development),
        :reloading_environments     => %w(development),
        :polling_environments       => %w(development),
        :poll_interval              => 0,
        :synchronization_data_file  => File.join('log', 'localeapp.yml'),
        :daemon_pid_file            => File.join('tmp', 'pids', 'localeapp.pid'),
        :daemon_log_file            => File.join('log', 'localeapp_daemon.log'),
        :translation_data_directory => File.join('config', 'locales'),
        :raise_on_insecure_yaml     => true,
      }
      if ENV['DEBUG']
        require 'logger'
        defaults[:logger] = Logger.new(STDOUT)
      end
      defaults
    end

    def polling_disabled?
      !polling_environments.map { |v| v.to_s }.include?(environment_name)
    end

    def reloading_disabled?
      !reloading_environments.map { |v| v.to_s }.include?(environment_name)
    end

    def sending_disabled?
      !sending_environments.map { |v| v.to_s }.include?(environment_name)
    end

    def has_api_key?
      !api_key.nil? && !api_key.empty?
    end

  end
end
