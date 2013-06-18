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

  it "preserves the :default param when the current locale is the default locale" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', 'bar', { :baz => 'bam', :default => 'default value' })
    translations[:en]['foo'].options.should == { :baz => 'bam', :default => 'default value' }
  end

  it "strips the :default param when the current locale is not the default locale" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:fr, 'foo', 'bar', { :baz => 'bam', :default => 'default value' })
    translations[:fr]['foo'].options.should == { :baz => 'bam' }
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

  it "caches the result of #to_send" do
    with_configuration(:cache_missing_translations => true) do
      translations_a = Localeapp::MissingTranslations.new
      translations_a.add(:es, 'foobybar', 'baz')
      to_send = translations_a.to_send
      to_send.size.should == 1

      translations_b = Localeapp::MissingTranslations.new
      translations_b.add(:es, 'foobybar', 'baz')
      to_send = translations_b.to_send
      to_send.size.should == 0
    end
  end
end
