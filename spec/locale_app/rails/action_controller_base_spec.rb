require 'spec_helper'

module ActionController
  class Base
    def self.before_filter(*options)
    end
  end
end

require 'locale_app/rails/action_controller_base'

describe ActionController::Base, '#handle_translation_updates' do
  before(:each) do
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
    @base = ActionController::Base.new
  end

  it "does nothing when configuration is disabled" do
    LocaleApp.configuration.environment_name = 'test'
    LocaleApp.poller.should_not_receive(:needs_polling?)
    @base.handle_translation_updates
  end

  it "proceeds when configuration is enabled" do
    LocaleApp.configuration.environment_name = 'development'
    LocaleApp.poller.should_receive(:needs_polling?)
    @base.handle_translation_updates
  end
end