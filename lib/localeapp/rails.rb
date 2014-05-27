require 'fileutils'

module Localeapp
  module Rails
    def self.initialize

      ActionController::Base.send(:include, Localeapp::Rails::Controller)

      if rails_version_matches? '~> 2.3' # TODO: Check previous rails versions if required
        require 'localeapp/rails/2_3_translation_helper_monkeypatch'
      end

      if rails_version_matches_any? '~> 3.2.16', '~> 4.0.2' # ie: after CVE-2013-4491 patch (https://github.com/rails/rails/commit/78790e4bceedc632cb40f9597792d7e27234138a)
        require 'localeapp/rails/force_exception_handler_in_translation_helper'
        require 'localeapp/rails/mimic_rails_missing_translation_display'
      end

      Localeapp.configure do |config|
        config.logger                     = rails_logger
        config.environment_name           = rails_env
        config.project_root               = rails_root
        config.synchronization_data_file  = File.join([config.project_root, 'log', 'localeapp.yml'])
        config.translation_data_directory = File.join([config.project_root, 'config', 'locales'])
      end
      initialize_synchronization_data_file
    end

    def self.initialize_synchronization_data_file
      sync_file = Localeapp.configuration.synchronization_data_file
      if !File.exist?(sync_file)
        FileUtils.mkdir_p(File.dirname(sync_file))
        file = Localeapp::SyncFile.new(sync_file)
        file.write(Time.now.to_i, Time.now.to_i)
      end
    end

    protected

    def self.rails_logger
      if defined?(::Rails.logger)
        ::Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end

    def self.rails_env
      if defined?(::Rails.env)
        ::Rails.env
      elsif defined?(RAILS_ENV)
        RAILS_ENV
      end
    end

    def self.rails_root
      if defined?(::Rails.root)
        ::Rails.root
      elsif defined?(RAILS_ROOT)
        RAILS_ROOT
      end
    end

    def self.rails_version_matches?(requirement)
      Gem::Requirement.new(requirement).satisfied_by? Gem::Version.new(::Rails::VERSION::STRING)
    end

    def self.rails_version_matches_any?(*requirements)
      requirements.map{ |r| rails_version_matches?(r) }.reduce(:|)
    end

  end
end

if defined?(Rails)
  require 'localeapp/rails/controller'
  require 'localeapp/exception_handler'
  Localeapp::Rails.initialize
  Localeapp.log('Loaded localeapp/rails')
end
