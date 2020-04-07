require 'fileutils'

module Localeapp
  module Rails
    def self.initialize

      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Localeapp::Rails::Controller)
      end

      # match all versions between https://github.com/rails/rails/commit/d57ce232a885b21e1d6d1f9fbf60bc5908ad880d and https://github.com/rails/rails/commit/4dbce79e95e3f56a9b48992dea4531493a5008cc on all branches
      if rails_version_matches_all?('~> 4.0.10.rc1') |
         rails_version_matches_all?('~> 4.1.0.rc1', '< 4.1.10.rc1') |
         rails_version_matches_all?('~> 4.2.0.beta1', '< 4.2.1.rc1')
        require 'localeapp/rails/backport_translation_helper_fix_to_honor_raise_option'
      end

      # match all versions after CVE-2013-4491 patch (https://github.com/rails/rails/commit/78790e4bceedc632cb40f9597792d7e27234138a)
      if rails_version_matches_any? '~> 3.2.16', '>= 4.0.2'
        require 'localeapp/rails/mimic_rails_missing_translation_display'
        require 'localeapp/rails/force_exception_handler_in_translation_helper'
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

    def self.rails_version_matches_all?(*requirements)
      requirements.map{ |r| rails_version_matches?(r) }.reduce(:&)
    end

  end
end

if defined?(Rails)
  require 'localeapp/rails/controller'
  require 'localeapp/exception_handler'
  Localeapp::Rails.initialize
  Localeapp.log('Loaded localeapp/rails')
end
