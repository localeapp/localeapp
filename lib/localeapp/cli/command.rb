module Localeapp
  module CLI
    class Command
      def initialize(args = {})
        initialize_config(args)
        @output = args[:output] || $stdout
      end

      # requires the Localeapp configuration
      def initialize_config(args = {})
        Localeapp.configure # load defaults
        load_config_file
        set_command_line_arguments(args)
      end

      def set_command_line_arguments(args = {})
        sanitized_args = {}
        if args[:k]
          sanitized_args[:api_key] = args[:k]
        end
        sanitized_args.each do |setting, value|
          Localeapp.configuration.send("#{setting}=", value)
        end
      end

      def load_config_file
        Localeapp.default_config_file_paths.each do |path|
          next unless File.exist? path
          require path
        end
      end
    end
  end
end
