require 'spec_helper'

class TestController
  def self.before_filter(*options)
  end
  def self.after_filter(*options)
  end
end

require 'localeapp/rails/controller'

describe Localeapp::Rails::Controller, '#handle_translation_updates' do
  before do
    TestController.send(:include, Localeapp::Rails::Controller)
    configuration = {
      :synchronization_data_file => LocaleappSynchronizationData::setup,
      :api_key => "my_key"
    }
    with_configuration(configuration) do
      @controller = TestController.new
    end
    now = Time.now; Time.stub(:now).and_return(now)
  end

  after do
    LocaleappSynchronizationData::destroy
  end

  context "when polling is enabled" do
    before do
      Localeapp.configuration.environment_name = 'development'
    end

    it "calls poller.poll! when the synchronization file's polled_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      Localeapp.poller.should_receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't call poller.poll! when the synchronization file's polled_at is the same" do
      Localeapp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "when polling is disabled" do
    before do
      Localeapp.configuration.environment_name = 'production'
    end

    it "doesn't poller.poll! when the synchronization file's polled_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      Localeapp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't poller.poll! when the synchronization file's polled_at is the same" do
      Localeapp.poller.should_not_receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "when reloading is enabled" do
    before do
      Localeapp.configuration.environment_name = 'development'
      Localeapp.poller.stub(:poll!)
    end

    it "calls I18n.reload! when the synchronization file's updated_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
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
      Localeapp.configuration.environment_name = 'production'
    end

    it "doesn't call I18n.reload! when the synchronization file's updated_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      I18n.should_not_receive(:reload!)
      @controller.handle_translation_updates
    end

    it "doesn't call I18n.relaod! when the synchronization file's updated_at is the same" do
      I18n.should_not_receive(:reload!)
      @controller.handle_translation_updates
    end
  end

  context "when an api_key is missing" do
    before do
      Localeapp.configuration.api_key = nil
    end

    it "raises an exception" do
      expect { @controller.handle_translation_updates }.to raise_error Localeapp::MissingApiKey
    end
  end

  context "when the api_key is empty" do
    before do
      Localeapp.configuration.api_key = ''
    end

    it "raises an exception" do
      expect { @controller.handle_translation_updates }.to raise_error Localeapp::MissingApiKey
    end
  end
end

describe Localeapp::Rails::Controller, '#send_missing_translations' do
  before(:each) do
    Localeapp.configure do |config|
      config.api_key = 'abcdef'
    end
    TestController.send(:include, Localeapp::Rails::Controller)
    @controller = TestController.new
  end

  it "does nothing when sending is disabled" do
    Localeapp.configuration.environment_name = 'test'
    Localeapp.sender.should_not_receive(:post_missing_translations)
    @controller.send_missing_translations
  end

  it "proceeds when configuration is enabled" do
    Localeapp.configuration.environment_name = 'development'
    Localeapp.sender.should_receive(:post_missing_translations)
    @controller.send_missing_translations
  end

  it "rejects blacklisted translations" do
    Localeapp.configuration.environment_name = 'development'
    Localeapp.missing_translations.should_receive(:reject_blacklisted)
    @controller.send_missing_translations
  end
end
