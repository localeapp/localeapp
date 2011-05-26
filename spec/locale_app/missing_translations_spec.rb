require 'spec_helper'
require 'locale_app/missing_translations'

describe LocaleApp::MissingTranslations, "#add(locale, key, options = {})" do
  it "stores the missing translation data" do
    translations = LocaleApp::MissingTranslations.new
    translations.add(:en, 'foo', { :baz => 'bam' })
    translations[:en].should include('foo')
    translations[:en]['foo'].options.should == { :baz => 'bam' }
  end
end

describe LocaleApp::MissingTranslations, "#to_send" do
  it "returns an array of missing translation data that needs to be sent to localeapp.com" do
    translations = LocaleApp::MissingTranslations.new
    translations.add(:en, 'foo', { :baz => 'bam' })
    translations.add(:es, 'bar')

    translations.to_send.should == [
      { :key => 'foo', :locale => :en, :options => { :baz => 'bam' } },
      { :key => 'bar', :locale => :es, :options => {}}
    ]
  end
end
