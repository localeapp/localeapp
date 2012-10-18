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
        attr_reader :valid_key, :project_data, :config_file_path, :data_directory

        def initialize(output)
          @output = output
        end

        def execute(key = nil)
          print_header
          validate_key(key)
          if valid_key
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

        def validate_key(key)
          @output.puts "Checking API key: #{key}"
          if key.nil?
            @output.puts "ERROR: You must supply an API key"
            @valid_key = false
            return
          end

          @valid_key, @project_data = check_key(key)
          if @valid_key
            @output.puts "Success!"
            @output.puts "Project: #{project_data['name']}"
          else
            @output.puts "ERROR: Project not found"
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
          Localeapp.configuration.write_rails_configuration(config_file_path)
        end

        def check_data_directory_exists
          unless File.directory?(data_directory)
            @output.puts "WARNING: please create the #{data_directory} directory. Your translation data will be stored there."
          end
        end

        def check_key(key)
          Localeapp::KeyChecker.new.check(key)
        end
      end

      class HerokuInstaller < DefaultInstaller
        def validate_key(key)
          @output.puts "Getting API key from heroku config"
          key = get_heroku_api_key
          if key.nil?
            @output.puts "ERROR: No api key found in heroku config, have you installed the localeapp addon?"
            return
          else
            @output.puts "API Key: #{key}"
          end
          super
        end

        # AUDIT: Need to find a less hacky way of doing this
        def get_heroku_api_key
          if ENV['CUCUMBER_HEROKU_TEST_API_KEY']
            ENV['CUCUMBER_HEROKU_TEST_API_KEY']
          else
            @output.puts `pwd`
            config_lines = `heroku config -s`
            if $? == 0
              config_line = config_lines.lines.grep(/LOCALEAPP_API_KEY/).first.chomp
              config_line.sub('LOCALEAPP_API_KEY=', '')
            else
              nil
            end
          end
        end
      end

      class GithubInstaller < DefaultInstaller
        def set_config_paths
          @config_file_path = ".localeapp/config.rb"
          @data_directory   = "locales"
        end

        def write_config_file
          Localeapp.configuration.write_github_configuration(config_file_path, project_data)
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
          Localeapp.configuration.write_standalone_configuration(config_file_path)
        end
      end
    end
  end
end
