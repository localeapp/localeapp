require 'spec_helper'
require 'localeapp/missing_translations'

describe Localeapp::MissingTranslations, "#add(locale, key, description = nil, options = {})" do
  it "stores the missing translation data" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', 'bar', { :baz => 'bam' })
    translations[:en].should include('foo')
    translations[:en]['foo'].description.should == 'bar'
    translations[:en]['foo'].options.should == { :baz => 'bam' }
  end

  it "respects I18n options when constructing a key" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', nil, { :scope => 'bar', :baz => 'bam' })

    translations[:en].should include('bar.foo')
    translations[:en]['bar.foo'].options.should == { :baz => 'bam' }
  end
end

describe Localeapp::MissingTranslations, "#to_send" do
  it "returns an array of missing translation data that needs to be sent to localeapp.com" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', nil, { :baz => 'bam' })
    translations.add(:es, 'bar', 'baz')

    to_send = translations.to_send
    to_send.size.should == 2
    to_send[0][:key].should == 'foo'
    to_send[0][:locale].should == :en
    to_send[0].should_not have_key(:description)
    to_send[0][:options].should == { :baz => 'bam' }
    to_send[1][:key].should == 'bar'
    to_send[1][:locale].should == :es
    to_send[1][:description].should == 'baz'
    to_send[1][:options].should == {}
  end

  it "doesn't send the same key twice when cache_missing_translations is true" do
    with_configuration(:cache_missing_translations => true) do
      translation_a = Localeapp::MissingTranslations.new
      translation_a.add(:es, 'foobybar')
      translation_a.to_send.size.should == 1

      translation_b = Localeapp::MissingTranslations.new
      translation_b.add(:en, 'foobybar')
      translation_a.to_send.size.should == 0
    end
  end

  it "can send the same key twice when cache_missing_translations is false" do
    with_configuration(:cache_missing_translations => false) do
      translation_a = Localeapp::MissingTranslations.new
      translation_a.add(:es, 'foobybar')
      translation_a.to_send.size.should == 1

      translation_b = Localeapp::MissingTranslations.new
      translation_b.add(:en, 'foobybar')
      translation_a.to_send.size.should == 1
    end
  end
end
