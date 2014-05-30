module Localeapp
  module CLI
    class Install < Command
      attr_accessor :config_type

      def initialize(args = {})
        super
        @config_type = :default
      end

      def execute(key = nil)
        installer("#{config_type.to_s.capitalize}Installer").execute(key)
      end

      def installer(installer_class)
        self.class.const_get(installer_class).new(@output)
      end

      class DefaultInstaller
        attr_accessor :key, :project_data, :config_file_path, :data_directory

        def initialize(output)
          @output = output
        end

        def execute(key = nil)
          self.key = key
          print_header
          if validate_key
            check_default_locale
            set_config_paths
            @output.puts "Writing configuration file to #{config_file_path}"
            write_config_file
            check_data_directory_exists
            true
          else
            false
          end
        end

        def print_header
          @output.puts "Localeapp Install"
          @output.puts ""
        end

        def validate_key
          @output.puts "Checking API key: #{key}"
          if key.nil?
            @output.puts "ERROR: You must supply an API key"
            return false
          end

          valid_key, @project_data = check_key(key)
          if valid_key
            @output.puts "Success!"
            @output.puts "Project: #{project_data['name']}"
            true
          else
            @output.puts "ERROR: Project not found"
            false
          end
        end

        def check_default_locale
          localeapp_default_code = project_data['default_locale']['code']
          @output.puts "Default Locale: #{localeapp_default_code} (#{project_data['default_locale']['name']})"
          if I18n.default_locale.to_s != localeapp_default_code
            @output.puts "WARNING: I18n.default_locale is #{I18n.default_locale}, change in config/environment.rb (Rails 2) or config/application.rb (Rails 3)"
          end
        end

        def set_config_paths
          @config_file_path = "config/initializers/localeapp.rb"
          @data_directory   = "config/locales"
        end

        def write_config_file
          create_config_dir
          write_rails_config
        end

        def write_rails_config
          File.open(config_file_path, 'w+') do |file|
            file.write <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = '#{key}'
end
CONTENT
          end
        end

        def check_data_directory_exists
          unless File.directory?(data_directory)
            @output.puts "WARNING: please create the #{data_directory} directory. Your translation data will be stored there."
          end
        end

        def check_key(key)
          Localeapp::KeyChecker.new.check(key)
        end

        private
        def config_dir
          File.dirname(config_file_path)
        end

        def create_config_dir
          FileUtils.mkdir_p(config_dir)
        end
      end

      class HerokuInstaller < DefaultInstaller
        def validate_key
          @output.puts "Getting API key from heroku config"
          get_heroku_api_key
          if key.nil?
            @output.puts "ERROR: No api key found in heroku config, have you installed the localeapp addon?"
            return
          else
            @output.puts "Add the following line to your .env file for Foreman"
            @output.puts "LOCALEAPP_API_KEY=#{key}"
            @output.puts '^' * 80
          end
          super
        end

        def get_heroku_api_key
          self.key = if ENV['CUCUMBER_HEROKU_TEST_API_KEY']
            ENV['CUCUMBER_HEROKU_TEST_API_KEY']
          elsif ENV['LOCALEAPP_API_KEY']
            ENV['LOCALEAPP_API_KEY']
          elsif File.exist?('.env') && IO.read('.env') =~ /^LOCALEAPP_API_KEY=(\w+)$/
            $1
          else
            nil
          end
        end

        def write_rails_config
          File.open(config_file_path, 'w+') do |file|
            file.write <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = ENV['LOCALEAPP_API_KEY']
  config.environment_name = ENV['LOCALEAPP_ENV'] unless ENV['LOCALEAPP_ENV'].nil?
  config.polling_environments = [:development, :staging]
  config.reloading_environments = [:development, :staging]
  config.sending_environments = [:development, :staging]
end

# Pull latest when dyno restarts on staging
if defined?(Rails) && Rails.env.staging?
  Localeapp::CLI::Pull.new.execute
end
CONTENT
          end
        end
      end

      class StandaloneInstaller < DefaultInstaller
        def check_default_locale
          # do nothing standalone
        end

        def set_config_paths
          @output.puts "NOTICE: you probably want to add .localeapp to your .gitignore file"
          @config_file_path = ".localeapp/config.rb"
          @data_directory   = "locales"
        end

        def write_config_file
          create_config_dir
          write_standalone_config
        end

        private
        def write_standalone_config
          File.open(config_file_path, 'w+') do |file|
            file.write <<-CONTENT
Localeapp.configure do |config|
  config.api_key                    = '#{key}'
  config.translation_data_directory = '#{data_directory}'
  config.synchronization_data_file  = '#{config_dir}/log.yml'
  config.daemon_pid_file            = '#{config_dir}/localeapp.pid'
end
CONTENT
          end
        end
      end

      class GithubInstaller < StandaloneInstaller
        def write_config_file
          super
          create_data_directory
          create_gitignore
          create_readme
        end

        private
        def create_data_directory
          FileUtils.mkdir_p(data_directory)
        end

        def create_gitignore
          File.open('.gitignore', 'a+') do |file|
            file.write "\n#{config_dir}"
          end
        end

        def create_readme
          File.open('README.md', 'a+') do |file|
            file.write <<-CONTENT

---

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
  end
end
