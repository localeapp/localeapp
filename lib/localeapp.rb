# AUDIT: Find a better way of doing this
begin
  require 'i18n'
rescue LoadError
  # we're in 2.3 and we need to load rails to get the vendored i18n
  require 'thread' # for rubygems > 1.6.0 support
  require 'active_support'
  # This ugliness so we can load AS in the travis env
  @loaded_active_support = true
end

begin
  require 'i18n/core_ext/hash'
rescue LoadError
  # This ugliness so we can load AS in the travis env
  # Assume that we're in rails 2.3 and AS supplies deep_merge
  # Load AS if we need to
  unless @loaded_active_support
    # we're in 2.3 and we need to load rails to get the vendored i18n
    require 'thread' # for rubygems > 1.6.0 support
    require 'active_support'
  end
end

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

# AUDIT: Will this work on ruby 1.9.x
$KCODE="UTF8" if RUBY_VERSION < '1.9'

require 'ya2yaml'

module Localeapp
  API_VERSION = "1"
  LOG_PREFIX = "** [Localeapp] "

  class LocaleappError < StandardError; end
  class PotentiallyInsecureYaml < LocaleappError; end
  class MissingApiKey < LocaleappError; end

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

      if defined?(Psych) && defined?(Psych::VERSION)
        Psych.load(contents)
      else
        normalize_results(YAML.load(contents))
      end
    end

    def load_yaml_file(filename)
      load_yaml(File.read(filename))
    end

    private

    def private_null_type(results)
      return true if results.is_a?(YAML::PrivateType) && results.type_id == 'null'
      if RUBY_PLATFORM == 'java'
        return true if results.is_a?(YAML::Yecht::PrivateType) && results.type_id == 'null'
      end
      false
    end

    def normalize_results(results)
      if private_null_type(results)
        nil
      elsif results.is_a?(Array)
        results.each_with_index do |value, i|
          results[i] = normalize_results(value)
        end
      elsif results.is_a?(Hash)
        results.each_pair do |key, value|
          results[key] = normalize_results(value)
        end
      else
        results
      end
    end
  end
end
