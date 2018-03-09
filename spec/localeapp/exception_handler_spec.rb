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

  it "handles when the default is a Symbol that can be resolved" do
    I18n.backend.store_translations(:en, {:default_symbol_test => 'is resolved'})
    expect(Localeapp.missing_translations).not_to receive(:add)
    expect(I18n.t(:foo, :default => :default_symbol_test)).to eq('is resolved')
  end

  it "handles when the default is a Symbol that can't be resolved" do
    expect(Localeapp.missing_translations).to receive(:add).with(:en, 'foo', nil, {:default => :bar})
    I18n.t(:foo, :default => :bar)
  end

  it "escapes html tags from keys to prevent xss attacks" do
    expect(Localeapp.missing_translations).to receive(:add).with(:en, '&lt;script&gt;alert(1);&lt;/script&gt;', nil, {})
    expect(I18n.t('<script>alert(1);</script>')).to eq 'en, &lt;script&gt;alert(1);&lt;/script&gt;'
  end

  it "joins locale and keys correctly" do
    expect(I18n.t('foo.bar')).to eq 'en, foo.bar'
    expect(I18n.t(%w{foo.bar foo.baz})).to eq 'en, foo.bar, foo.baz'
  end

  it "handles missing translation exception" do
    expect {
      exception = Localeapp::I18nMissingTranslationException.new(:en, 'foo', {})
      Localeapp::ExceptionHandler.call(exception, :en, 'foo', {})
    }.to_not raise_error
  end

  it "handles the scope option" do
    expect(I18n.t('foo.bar', scope: 'scoped')).to eq 'en, scoped.foo.bar'
    expect(I18n.t(%w{foo.bar foo.baz}, scope: 'scoped')).to eq 'en, scoped.foo.bar, scoped.foo.baz'
  end
end
