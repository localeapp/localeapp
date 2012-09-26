module Localeapp
  module CLI
    class Command
      def initialize(output = $stdout)
        Localeapp.initialize_config
        @output = output
      end
    end
  end
end
