require 'spec_helper'
require 'locale_app/rails/i18n'

describe I18n, '#locale_app_exception_handler(exception, locale, key, options)' do
  before(:each) do
    @exception = I18n::MissingTranslationData.new('en', 'foo.bar', {})
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "posts a translation when sending is enabled" do
    LocaleApp.configuration.environment_name = 'development'
    LocaleApp.sender.should_receive(:post_translation)
    I18n.locale_app_exception_handler(@exception, :en, 'foo.bar', {})
  end

  it "doesn't post a translation when sending is disabled" do
    LocaleApp.configuration.environment_name = 'test'
    LocaleApp.sender.should_not_receive(:post_translation)
    I18n.locale_app_exception_handler(@exception, :en, 'foo.bar', {})
  end
end