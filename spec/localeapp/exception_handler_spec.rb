require 'spec_helper'
require 'localeapp/exception_handler'

describe Localeapp::ExceptionHandler, '#call(exception, locale, key, options)' do
  before(:each) do
    Localeapp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "adds the missing translation to the missing translation list" do
    Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', nil, { :baz => 'bam' })
    I18n.t('foo', :baz => 'bam')
  end

  it "handles when the key is an array of keys" do
    Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', nil, {})
    Localeapp.missing_translations.should_receive(:add).with(:en, 'bar', nil, {})
    I18n.t(['foo', 'bar'])
  end

  it "handles missing translation exception" do
    expect {
      exception = Localeapp::I18nMissingTranslationException.new(:en, 'foo', {})
      Localeapp::ExceptionHandler.call(exception, :en, 'foo', {})
    }.to_not raise_error
  end
end
