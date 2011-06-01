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

    to_send = translations.to_send
    to_send.size.should == 2
    to_send[0][:key].should == 'foo'
    to_send[0][:locale].should == :en
    to_send[0][:options].should == { :baz => 'bam' }
    to_send[1][:key].should == 'bar'
    to_send[1][:locale].should == :es
    to_send[1][:options].should == {}
  end
end
