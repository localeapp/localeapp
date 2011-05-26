require 'spec_helper'

class TestController
  def self.before_filter(*options)
  end
  def self.after_filter(*options)
  end
end

require 'locale_app/rails/controller'

describe LocaleApp::Rails::Controller, '#handle_translation_updates' do
  before(:each) do
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
    TestController.send(:include, LocaleApp::Rails::Controller)
    @controller = TestController.new
  end

  it "does nothing when configuration is disabled" do
    LocaleApp.configuration.environment_name = 'test'
    LocaleApp.poller.should_not_receive(:needs_polling?)
    @controller.handle_translation_updates
  end

  it "proceeds when configuration is enabled" do
    LocaleApp.configuration.environment_name = 'development'
    LocaleApp.poller.should_receive(:needs_polling?)
    @controller.handle_translation_updates
  end
end

describe LocaleApp::Rails::Controller, '#send_missing_translations' do
  before(:each) do
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
    TestController.send(:include, LocaleApp::Rails::Controller)
    @controller = TestController.new
  end

  it "does nothing when sending is disabled" do
    LocaleApp.configuration.environment_name = 'test'
    LocaleApp.sender.should_not_receive(:post_missing_translations)
    @controller.send_missing_translations
  end

  it "proceeds when configuration is enabled" do
    LocaleApp.configuration.environment_name = 'development'
    LocaleApp.sender.should_receive(:post_missing_translations)
    @controller.send_missing_translations
  end
end
