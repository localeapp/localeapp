require 'i18n'
require 'i18n/core_ext/hash'
require 'yaml'

require 'localeapp/i18n_shim'
require 'localeapp/version'
require 'localeapp/configuration'
require 'localeapp/routes'
require 'localeapp/api_call'
require 'localeapp/api_caller'
require 'localeapp/sender'
require 'localeapp/sync_file'
require 'localeapp/poller'
require 'localeapp/updater'
require 'localeapp/key_checker'
require 'localeapp/missing_translations'
require 'localeapp/default_value_handler'

require 'localeapp/cli/command'
require 'localeapp/cli/install'
require 'localeapp/cli/pull'
require 'localeapp/cli/push'
require 'localeapp/cli/update'
require 'localeapp/cli/add'
require 'localeapp/cli/remove'
require 'localeapp/cli/rename'
require 'localeapp/cli/daemon'

module Localeapp
  API_VERSION = "1"
  LOG_PREFIX = "** [Localeapp] "
  ENV_FILE_PATH = ".env".freeze

  class LocaleappError < StandardError; end
  class PotentiallyInsecureYaml < LocaleappError; end
  class MissingApiKey < LocaleappError; end
  class RuntimeError < LocaleappError; end
  class APIResponseError < RuntimeError; end

  class << self
    # An Localeapp configuration object.
    attr_accessor :configuration

    # The sender object is responsible for delivering formatted data to the Localeapp server.
    attr_accessor :sender

    # The poller object is responsible for retrieving data for the Localeapp server
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

    def log_with_time(message)
      log [Time.now.to_i, message].join(' - ')
    end

    def debug(message)
      logger.debug(LOG_PREFIX + message) if logger
    end

    # Look for the Rails logger currently defined
    def logger
      self.configuration && self.configuration.logger
    end

    # @example Configuration
    # Localeapp.configure do |config|
    #   config.api_key = '1234567890abcdef'
    # end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      self.sender  = Sender.new
      self.poller  = Poller.new
      self.updater = Updater.new
      @missing_translations = MissingTranslations.new
    end

    def has_config_file?
      default_config_file_paths.any? { |path| File.exist?(path) }
    end

    def default_config_file_paths
      [
        File.join(Dir.pwd, '.localeapp', 'config.rb'),
        File.join(Dir.pwd, 'config', 'initializers', 'localeapp.rb')
      ]
    end

    def load_yaml(contents)
      if Localeapp.configuration.raise_on_insecure_yaml
        raise Localeapp::PotentiallyInsecureYaml if contents =~ /!ruby\//
      end

      YAML.load(contents)
    end

    def load_yaml_file(filename)
      load_yaml(File.read(filename))
    end

    def env_file_path
      ENV_FILE_PATH
    end

    private

    def private_null_type(results)
      return true if results.is_a?(YAML::PrivateType) && results.type_id == 'null'
      if RUBY_PLATFORM == 'java'
        return true if results.is_a?(YAML::Yecht::PrivateType) && results.type_id == 'null'
      end
      false
    end
  end
end
