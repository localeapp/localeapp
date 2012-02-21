module Localeapp
  module CLI
    class Install
      attr_accessor :config_type

      def initialize
        @config_type = :rails
      end

      def execute(key, output = $stdout)
        output.puts "Localeapp Install"
        output.puts ""
        output.puts "Checking API key: #{key}"
        if key.nil?
          output.puts "ERROR: You must supply an API key"
          return
        end
        valid_key, project_data = check_key(key)
        if valid_key
          output.puts "Success!"
          output.puts "Project: #{project_data['name']}"
          localeapp_default_code = project_data['default_locale']['code']
          output.puts "Default Locale: #{localeapp_default_code} (#{project_data['default_locale']['name']})"

          if config_type == :rails
            if I18n.default_locale.to_s != localeapp_default_code
              output.puts "WARNING: I18n.default_locale is #{I18n.default_locale}, change in config/environment.rb (Rails 2) or config/application.rb (Rails 3)"
            end
            config_file_path = "config/initializers/localeapp.rb"
            data_directory   = "config/locales"
          else
            output.puts "NOTICE: you probably want to add .localeapp to your .gitignore file"
            config_file_path = ".localeapp/config.rb"
            data_directory   = "locales"
          end
          output.puts "Writing configuration file to #{config_file_path}"
          write_configuration_file config_file_path

          unless Dir.exist?(data_directory)
            output.puts "WARNING: please create the #{data_directory} directory. Your translation data will be stored there."
          end
          true
        else
          output.puts "ERROR: Project not found"
          false
        end
      end

      private
      def check_key(key)
        Localeapp::KeyChecker.new.check(key)
      end

      def write_configuration_file(path)
        if config_type == :rails
          Localeapp.configuration.write_rails_configuration(path)
        else
          Localeapp.configuration.write_dot_file_configuration(path)
        end
      end
    end
  end
end
