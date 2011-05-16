require 'locale_app/version'
require 'locale_app/configuration'
require 'locale_app/routes'
require 'locale_app/sender'
require 'locale_app/poller'
require 'locale_app/updater'
require 'locale_app/key_checker'
  
require 'locale_app/cli/install'
require 'locale_app/cli/pull'
require 'locale_app/cli/push'

# AUDIT: Will this work on ruby 1.9.x
$KCODE="UTF8" if RUBY_VERSION < '1.9'

require 'ya2yaml'

module LocaleApp
  API_VERSION = "1"
  LOG_PREFIX = "** [LocaleApp] "

  class << self
    # An LocaleApp configuration object.
    attr_accessor :configuration
    
    # The sender object is responsible for delivering formatted data to the LocaleApp server.
    attr_accessor :sender

    # The poller object is responsible for retrieving data for the LocaleApp server
    attr_accessor :poller

    # The updater object is responsible for merging translations into the i18n backend
    attr_accessor :updater


    # Writes out the given message to the #logger
    def log(message)
      logger.info LOG_PREFIX + message if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration.logger
    end
  
    # @example Configuration
    # LocaleApp.configure do |config|
    #   config.api_key = '1234567890abcdef'
    # end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.sender  = Sender.new
      self.poller  = Poller.new
      self.updater = Updater.new
    end

    # requires the LocaleApp configuration
    def include_config_file(file_path=nil)
      file_path ||= File.join(Dir.pwd, 'config', 'initializers', 'locale_app')
      begin
        require file_path
        true
      rescue
        false
      end
    end
  end
end
