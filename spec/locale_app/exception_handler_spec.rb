require 'spec_helper'
require 'locale_app/exception_handler'

describe LocaleApp::ExceptionHandler, '#call(exception, locale, key, options)' do
  before(:each) do
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "posts a translation when sending is enabled" do
    LocaleApp.configuration.environment_name = 'development'
    LocaleApp.sender.should_receive(:post_translation)
    I18n.t('foo')
  end

  it "doesn't post a translation when sending is disabled" do
    LocaleApp.configuration.environment_name = 'test'
    LocaleApp.sender.should_not_receive(:post_translation)
    I18n.t('foo')
  end
end
