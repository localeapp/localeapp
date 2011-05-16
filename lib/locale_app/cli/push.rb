module LocaleApp
  module CLI
    class Push
      include ::LocaleApp::Routes

      def execute(file = nil, output = $stdout)
        output.puts "LocaleApp Push"
        output.puts ""

        unless File.exist?(file)
          output.puts "Could not load file"
          return
        end
        
        output.puts "Pushing file:"
        response = RestClient.post(import_url, :file => File.new(file))
        if response.code == 200
          puts "Success!"
          puts ""
          puts "#{file} queued for processing."
        else
          puts "Failed!"
        end
      end

    end
  end
end