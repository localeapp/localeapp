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
      
      Olba.configure do |config|
        config.logger           = rails_logger
        config.environment_name = rails_env
      end
    end
  end
end

Olba::Rails.initialize
Olba.log('Loaded olba/rails')
