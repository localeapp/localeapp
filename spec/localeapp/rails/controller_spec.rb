require 'spec_helper'

class TestController
  def self.before_filter(*options)
  end
  def self.after_filter(*options)
  end
end

class TestActionController
  def self.before_action(*options)
  end
  def self.after_action(*options)
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
    now = Time.now; allow(Time).to receive(:now).and_return(now)
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
      expect(Localeapp.poller).to receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't call poller.poll! when the synchronization file's polled_at is the same" do
      expect(Localeapp.poller).not_to receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "when polling is disabled" do
    before do
      Localeapp.configuration.environment_name = 'production'
    end

    it "doesn't poller.poll! when the synchronization file's polled_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      expect(Localeapp.poller).not_to receive(:poll!)
      @controller.handle_translation_updates
    end

    it "doesn't poller.poll! when the synchronization file's polled_at is the same" do
      expect(Localeapp.poller).not_to receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "when reloading is enabled" do
    before do
      Localeapp.configuration.environment_name = 'development'
      allow(Localeapp.poller).to receive(:poll!)
    end

    it "calls I18n.reload! when the synchronization file's updated_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      expect(I18n).to receive(:reload!)
      @controller.handle_translation_updates
    end

    it "doesn't call I18n.relaod! when the synchronization file's updated_at is the same" do
      expect(I18n).not_to receive(:reload!)
      @controller.handle_translation_updates
    end
  end

  context "when reloading is disabled" do
    before do
      Localeapp.configuration.environment_name = 'production'
    end

    it "doesn't call I18n.reload! when the synchronization file's updated_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      expect(I18n).not_to receive(:reload!)
      @controller.handle_translation_updates
    end

    it "doesn't call I18n.relaod! when the synchronization file's updated_at is the same" do
      expect(I18n).not_to receive(:reload!)
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
    expect(Localeapp.sender).not_to receive(:post_missing_translations)
    @controller.send_missing_translations
  end

  it "proceeds when configuration is enabled" do
    Localeapp.configuration.environment_name = 'development'
    expect(Localeapp.sender).to receive(:post_missing_translations)
    @controller.send_missing_translations
  end

  it "rejects blacklisted translations" do
    Localeapp.configuration.environment_name = 'development'
    expect(Localeapp.missing_translations).to receive(:reject_blacklisted)
    @controller.send_missing_translations
  end
end

describe Localeapp::Rails::Controller, 'Rails 5 before_action support' do
  before do
    TestActionController.send(:include, Localeapp::Rails::Controller)
    configuration = {
      :synchronization_data_file => LocaleappSynchronizationData::setup,
      :api_key => "my_key"
    }
    with_configuration(configuration) do
      @controller = TestActionController.new
    end
    now = Time.now; allow(Time).to receive(:now).and_return(now)
    Localeapp.configuration.environment_name = 'development'
  end

  context "#handle_translation_updates" do
    it "calls poller.poll! when the synchronization file's polled_at has changed" do
      Localeapp.poller.write_synchronization_data!(01234, 56789)
      expect(Localeapp.poller).to receive(:poll!)
      @controller.handle_translation_updates
    end
  end

  context "#send_missing_translations" do
    it "proceeds when configuration is enabled" do
      expect(Localeapp.sender).to receive(:post_missing_translations)
      @controller.send_missing_translations
    end
  end
end
