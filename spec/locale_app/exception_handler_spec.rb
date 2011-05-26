require 'spec_helper'
require 'locale_app/exception_handler'

describe LocaleApp::ExceptionHandler, '#call(exception, locale, key, options)' do
  before(:each) do
    LocaleApp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "adds the missing translation to the missing translation list" do
    LocaleApp.missing_translations.should_receive(:add).with(:en, 'foo', { :baz => 'bam' })
    I18n.t('foo', :baz => 'bam')
  end
end
