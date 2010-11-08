require 'locale_app/version'
require 'locale_app/configuration'
require 'locale_app/sender'
require 'locale_app/receiver'

module LocaleApp
  API_VERSION = "1"
  LOG_PREFIX = "** [LocaleApp] "

  class << self
    # An LocaleApp configuration object.
    attr_accessor :configuration
    
    # The sender object is responsible for delivering formatted data to the LocaleApp server.
    attr_accessor :sender

    # The receiver object is responsible for retrieving data for the LocaleApp server
    attr_accessor :receiver


    # Writes out the given message to the #logger
    def log(message)
      logger.info LOG_PREFIX + message if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration.logger
    end
  
    # @example
    # LocaleApp.configure do |config|
    #   config.api_key = '1234567890abcdef'
    # end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.sender = Sender.new
      self.receiver = Receiver.new
    end

  end
end
