module Localeapp
  module CLI
    class Command
      def initialize(output = $stdout)
        @output = output
      end
    end
  end
end
