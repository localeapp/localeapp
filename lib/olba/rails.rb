require 'olba/rails/action_controller_base'
require 'olba/rails/i18n'
require 'olba/rails/translation_helper'

module Olba
  module Rails
    def self.initialize
      if defined?(::Rails.logger)
        rails_logger = ::Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        rails_logger = RAILS_DEFAULT_LOGGER
      end

      if defined?(::Rails.env)
        rails_env = ::Rails.env
      elsif defined?(RAILS_ENV)
        rails_env = RAILS_ENV
      end

      if defined?(::Rails.root)
        rails_root = ::Rails.root
      elsif defined?(RAILS_ROOT)
        rails_root = RAILS_ROOT
      end
      
      Olba.configure do |config|
        config.logger           = rails_logger
        config.environment_name = rails_env
        config.project_root     = rails_root
        config.cluster_log      = File.join([rails_root, 'log', 'olba.yml'])
        config.locale_file      = File.join([rails_root, 'config', 'locales', 'olba.yml'])
      end
      initialize_cluster_log
      initialize_locale_file
    end

    def self.initialize_cluster_log
      if !File.exists?(Olba.configuration.cluster_log)
        File.open(Olba.configuration.cluster_log, 'w') do |f|
          f.write({:polled_at => Time.now.to_i, :updated_at => Time.now.to_i}.to_yaml)
        end
      end
    end

    def self.initialize_locale_file
      if !File.exists?(Olba.configuration.locale_file)
        File.open(Olba.configuration.locale_file, 'w') do |f|
          translations = {}
          translations['en'] = {'olba' => 'Olba'}
          f.write(translations.to_yaml)
        end
      end
    end
    
  end
end

Olba::Rails.initialize
Olba.log('Loaded olba/rails')
