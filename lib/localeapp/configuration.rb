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

    def initialize
      @host                            = 'api.localeapp.com'
      @secure                          = true
      @ssl_verify                      = false
      @sending_environments            = %w(development)
      @reloading_environments          = %w(development)
      @polling_environments            = %w(development)
      @poll_interval                   = 0
      @synchronization_data_file       = File.join('log', 'localeapp.yml')
      @daemon_pid_file                 = File.join('tmp', 'pids', 'localeapp.pid')
      @daemon_log_file                 = File.join('log', 'localeapp_daemon.log')
      @translation_data_directory      = File.join('config', 'locales')
      if ENV['DEBUG']
        require 'logger'
        @logger = Logger.new(STDOUT)
      end
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

    def write_standalone_configuration(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.open(path, 'w+') do |file|
        file.write <<-CONTENT
Localeapp.configure do |config|
  config.api_key                    = '#{@api_key}'
  config.translation_data_directory = 'locales'
  config.synchronization_data_file  = '.localeapp/log.yml'
  config.daemon_pid_file            = '.localeapp/localeapp.pid'
end
CONTENT
      end
    end

    def write_github_configuration(path, project_data)
      write_standalone_configuration(path)
      FileUtils.mkdir_p('locales')
      File.open('.gitignore', 'a+') do |file|
        file.write ".localeapp"
      end
      File.open('README.md', 'w+') do |file|
        file.write <<-CONTENT
# #{project_data['name']}

A ruby translation project managed on [Locale](http://www.localeapp.com/) that's open to all!

## Contributing to #{project_data['name']}

- Edit the translations directly on the [#{project_data['name']}](http://www.localeapp.com/projects/public?search=#{project_data['name']}) project on Locale.
- **That's it!**
- The maintainer will then pull translations from the Locale project and push to Github.

Happy translating!
CONTENT
      end
    end

  end
end
