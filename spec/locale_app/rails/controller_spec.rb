require 'spec_helper'

class TestController
  def self.before_filter(*options)
  end
  def self.after_filter(*options)
  end
end

require 'locale_app/rails/controller'

describe LocaleApp::Rails::Controller, '#handle_translation_updates' do
  before do
    TestController.send(:include, LocaleApp::Rails::Controller)
    with_configuration(:synchronization_data_file => LocaleAppSynchronizationData::setup) do
      @controller = TestController.new
    end
  end

  after do
    LocaleAppSynchronizationData::destroy
  end

  context "when polling is enabled" do
    before do
      LocaleApp.configuration.environment_name = 'development' # reloading enabled
      LocaleApp.configuration.disabled_reloading_environments << 'development'
    end
 
    it "calls poller.poll! when the synchronization file's polled_at has changed" do
      LocaleApp.poller.write_synchronization_data!(01234, 56789)
      LocaleApp.poller.should_receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't call poller.poll! when the synchronization file's polled_at is the same" do
      LocaleApp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "when polling is disabled" do
    before do
      LocaleApp.configuration.environment_name = 'production' # reloading disabled
      LocaleApp.configuration.disabled_reloading_environments << 'production'
    end

    it "doesn't poller.poll! when the synchronization file's polled_at has changed" do
      LocaleApp.poller.write_synchronization_data!(01234, 56789)
      LocaleApp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't poller.poll! when the synchronization file's polled_at is the same" do
      LocaleApp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end
  end
 
  context "when reloading is enabled" do
    before do
      LocaleApp.configuration.environment_name = 'development' # reloading enabled
      LocaleApp.configuration.disabled_polling_environments << 'development'
    end
 
    it "calls I18n.reload! when the synchronization file's updated_at has changed" do
      LocaleApp.poller.write_synchronization_data!(01234, 56789)
      I18n.should_receive(:reload!)
      @controller.handle_translation_updates
    end

    it "doesn't call I18n.relaod! when the synchronization file's updated_at is the same" do
      I18n.should_not_receive(:reload!)
      @controller.handle_translation_updates
    end
  end
 
  context "when reloading is disabled" do
    before do
      LocaleApp.configuration.environment_name = 'production' # reloading disabled
      LocaleApp.configuration.disabled_polling_environments << 'production'
    end

    it "doesn't call I18n.reload! when the synchronization file's updated_at has changed" do
      LocaleApp.poller.write_synchronization_data!(01234, 56789)
      I18n.should_not_receive(:reload!)
      @controller.handle_translation_updates
    end

    it "doesn't call I18n.relaod! when the synchronization file's updated_at is the same" do
      I18n.should_not_receive(:reload!)
      @controller.handle_translation_updates
    end
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
