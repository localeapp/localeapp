require 'spec_helper'
require 'localeapp/exception_handler'

describe Localeapp::ExceptionHandler, '#call(exception, locale, key, options)' do
  before(:each) do
    Localeapp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "adds the missing translation to the missing translation list" do
    Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', { :baz => 'bam' })
    I18n.t('foo', :baz => 'bam')
  end

  it "handles when the key is an array of keys" do
    Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', {})
    Localeapp.missing_translations.should_receive(:add).with(:en, 'bar', {})
    I18n.t(['foo', 'bar'])
  end
end
