require 'olba/version'
require 'olba/configuration'
require 'olba/sender'

module Olba
  API_VERSION = "1"
  LOG_PREFIX = "** [Olba] "

  class << self
    # The sender object is responsible for delivering formatted data to the Olba server.
    attr_accessor :sender

    # An Olba configuration object.
    attr_accessor :configuration

    # Writes out the given message to the #logger
    def log(message)
      logger.info LOG_PREFIX + message if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration.logger
    end
  
    # @example
    # Olba.configure do |config|
    #   config.api_key = '1234567890abcdef'
    # end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.sender = Sender.new
    end

  end
end
