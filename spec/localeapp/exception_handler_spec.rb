require 'spec_helper'
require 'localeapp/exception_handler'

describe Localeapp::ExceptionHandler, '#call(exception, locale, key, options)' do
  before(:each) do
    Localeapp.configure do |config|
      config.api_key = 'abcdef'
    end
  end

  it "adds the missing translation to the missing translation list" do
    expect(Localeapp.missing_translations).to receive(:add).with(:en, 'foo', nil, { :baz => 'bam' })
    I18n.t('foo', :baz => 'bam')
  end

  it "handles when the key is an array of keys" do
    expect(Localeapp.missing_translations).to receive(:add).with(:en, 'foo', nil, {})
    expect(Localeapp.missing_translations).to receive(:add).with(:en, 'bar', nil, {})
    I18n.t(['foo', 'bar'])
  end

  it "delegates to super for handling of output" do
    expect(I18n.t('foo')).to eq("translation missing: en.foo")
  end

  it "delegates to super for handling of rescue_format" do
    expect(I18n.t('foo', :rescue_format => :html)).to eq("<span class=\"translation_missing\" title=\"translation missing: en.foo\">Foo</span>")
  end

  it "handles when the default is a Symbol that can be resolved" do
    I18n.backend.store_translations(:en, {:default_symbol_test => 'is resolved'})
    expect(Localeapp.missing_translations).not_to receive(:add)
    expect(I18n.t(:foo, :default => :default_symbol_test)).to eq('is resolved')
  end

  it "handles when the default is a Symbol that can't be resolved" do
    expect(Localeapp.missing_translations).to receive(:add).with(:en, :foo, nil, {:default => :bar})
    I18n.t(:foo, :default => :bar)
  end

  it "handles missing translation exception" do
    expect {
      exception = Localeapp::I18nMissingTranslationException.new(:en, 'foo', {})
      I18n::ExceptionHandler.new.call(exception, :en, 'foo', {})
    }.to_not raise_error
  end
end
