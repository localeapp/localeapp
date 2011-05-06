module LocaleApp
  module CLI
    class Pull
      include ::LocaleApp::Routes

      def execute(output = $stdout)
        output.puts "LocaleApp Pull"
        output.puts ""

        unless LocaleApp.include_config_file
          output.puts "Could not load config file"
          return
        end
        
        output.puts "Fetching translations:"
        response = RestClient.get(translations_url)
        if response.code == 200
          puts "Success!"
          puts "Updating backend:"
          LocaleApp.updater.update(JSON.parse(response))
          puts "Success!"
          LocaleApp.poller.write_synchronization_data!(Time.now.to_i, Time.now.to_i)
        end
      end

    end
  end
end