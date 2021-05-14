module Localeapp
  module CLI
    class Add < Command
      def execute(key, *translations)
        @output.puts "Localeapp Add"
        @output.puts ""
        # Those are just first thoughs, didn't went deep into this one
        # get all en translations
        # find potential aliases
        # if there is a match suggest reusing the key or copy it
        # add the promt from bellow
        # STDOUT.puts "An alias was found, suggest to use/copy it. Enter 'create' to confirm creating a new key:"
        # input = STDIN.gets.chomp
        # raise "Aborting creating key: #{key}. You entered #{input}" unless input == 'create'
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
