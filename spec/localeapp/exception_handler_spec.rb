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

  it "delegates to super for handling of output" do
    expect(I18n.t('foo', rescue_format: :html)).to eq("translation missing: foo")
  end

  it "delegates to super for handling of rescue_format" do
    expect(I18n.t('foo', rescue_format: :html)).to eq("<span class=\"translation_missing\" title=\"translation missing: en.foo\">Foo</span>")
  end

  it "handles missing translation exception" do
    expect {
      exception = Localeapp::I18nMissingTranslationException.new(:en, 'foo', {})
      Localeapp::ExceptionHandler.new.call(exception, :en, 'foo', {})
    }.to_not raise_error
  end
end
