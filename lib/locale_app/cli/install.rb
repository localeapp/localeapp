module LocaleApp
  module CLI
    class Install
      def execute(key, output = $stdout)
        output.puts "LocaleApp Install"
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
          output.puts "Default Locale: #{project_data['default_locale']['code']} (#{project_data['default_locale']['name']})"
          config_file_path = "config/initializers/locale_app.rb"
          output.puts "Writing configuration file to #{config_file_path}"
          write_configuration_file config_file_path
        else
          output.puts "ERROR: Project not found"
          return
        end
      end

      private
      def check_key(key)
        LocaleApp::KeyChecker.new.check(key)
      end

      def write_configuration_file(path)
        LocaleApp.configuration.write_initial(path)
      end
    end
  end
end
