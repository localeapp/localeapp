require 'spec_helper'
require 'locale_app/missing_translations'

describe LocaleApp::MissingTranslations, "#add(locale, key, options)" do
  it "stores the missing translation data" do
    translations = LocaleApp::MissingTranslations.new
    translations.add(:en, 'foo', { :baz => 'bam' })
    translations[:en].should include('foo')
    translations[:en]['foo'].options.should == { :baz => 'bam' }
  end
end
