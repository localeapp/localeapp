module Localeapp
  module CLI
    class Add
      def initialize(output = $stdout)
        @output = output
      end

      def execute(key, *translations)
        @output.puts "Localeapp Add"
        @output.puts ""
        translations.each do |translation|
          locale, description = translation.split(/:/)
          Localeapp.missing_translations.add(locale, key, description)
        end
        @output.puts "Sending key: #{key}"
        Localeapp.sender.post_missing_translations
        @output.puts "Success!"
      end
    end
  end
end
