module Localeapp
  module CLI
    class Add < Command
      def execute(key, *translations)
        @output.puts "Localeapp Add"
        @output.puts ""
        translations.each do |translation|
          if translation =~ /([\w\-]+):(.*)/m
            locale, description = $1, $2
            Localeapp.missing_translations.add(locale, key, description)
          else
            @output.puts "Ignoring bad translation #{translation}"
            @output.puts "format should be <locale>:<translation content>"
          end
        end
        @output.puts "Sending key: #{key}"
        Localeapp.sender.post_missing_translations
        @output.puts "Success!"
      end
    end
  end
end
