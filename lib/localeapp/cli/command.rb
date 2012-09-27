module Localeapp
  module CLI
    class Command
      def initialize(args = {})
        Localeapp.initialize_config
        @output = args[:output] || $stdout
      end
    end
  end
end
