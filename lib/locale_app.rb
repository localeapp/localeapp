# AUDIT: Find a better way of doing this
begin
  require 'i18n'
rescue LoadError
  # we're in 2.3 and we need to load rails to get the vendored i18n
  require 'thread' # for rubygems > 1.6.0 support
  require 'active_support'
end

begin
  require 'i18n/core_ext/hash'
rescue LoadError
  # Assume that we're in rails 2.3 and AS supplies deep_merge
end


require 'locale_app/version'
require 'locale_app/configuration'
require 'locale_app/routes'
require 'locale_app/api_call'
require 'locale_app/api_caller'
require 'locale_app/sender'
require 'locale_app/poller'
require 'locale_app/updater'
require 'locale_app/key_checker'
require 'locale_app/missing_translations'
  
require 'locale_app/cli/install'
require 'locale_app/cli/pull'
require 'locale_app/cli/push'
require 'locale_app/cli/update'

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

    # The missing_translations object is responsible for keeping track of missing translations
    # that will be sent to the backend
    attr_reader :missing_translations


    # Writes out the given message to the #logger
    def log(message)
      logger.info LOG_PREFIX + message if logger
    end

    def debug(message)
      logger.debug(LOG_PREFIX + message) if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration && self.configuration.logger
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
      @missing_translations = MissingTranslations.new
    end

    # requires the LocaleApp configuration
    def include_config_file(file_path=nil)
      file_path ||= File.join(Dir.pwd, 'config', 'initializers', 'localeapp')
      begin
        require file_path
        true
      rescue
        false
      end
    end
  end
end
