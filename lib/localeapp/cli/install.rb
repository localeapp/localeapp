module Localeapp
  module CLI
    class Install
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
          if I18n.default_locale.to_s != localeapp_default_code
            output.puts "WARNING: I18n.default_locale is #{I18n.default_locale}, change in config/environment.rb (Rails 2) or config/application.rb (Rails 3)"
          end
          config_file_path = "config/initializers/localeapp.rb"
          output.puts "Writing configuration file to #{config_file_path}"
          write_configuration_file config_file_path
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
        Localeapp.configuration.write_initial(path)
      end
    end
  end
end
