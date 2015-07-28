require 'spec_helper'
require 'localeapp/missing_translations'

describe Localeapp::MissingTranslations, "#add(locale, key, description = nil, options = {})" do
  it "stores the missing translation data" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', 'bar', { :baz => 'bam' })
    expect(translations[:en]).to include('foo')
    expect(translations[:en]['foo'].description).to eq('bar')
    expect(translations[:en]['foo'].options).to eq({ :baz => 'bam' })
  end

  it "respects I18n options when constructing a key" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', nil, { :scope => 'bar', :baz => 'bam' })

    expect(translations[:en]).to include('bar.foo')
    expect(translations[:en]['bar.foo'].options).to eq({ :baz => 'bam' })
  end
end

describe Localeapp::MissingTranslations, "#to_send" do
  it "returns an array of missing translation data that needs to be sent to localeapp.com" do
    translations = Localeapp::MissingTranslations.new
    translations.add(:en, 'foo', nil, { :baz => 'bam' })
    translations.add(:es, 'bar', 'baz')

    to_send = translations.to_send
    expect(to_send.size).to eq(2)
    expect(to_send[0][:key]).to eq('foo')
    expect(to_send[0][:locale]).to eq(:en)
    expect(to_send[0]).not_to have_key(:description)
    expect(to_send[0][:options]).to eq({ :baz => 'bam' })
    expect(to_send[1][:key]).to eq('bar')
    expect(to_send[1][:locale]).to eq(:es)
    expect(to_send[1][:description]).to eq('baz')
    expect(to_send[1][:options]).to eq({})
  end

  it "doesn't send the same key twice when cache_missing_translations is true" do
    with_configuration(:cache_missing_translations => true) do
      translation_a = Localeapp::MissingTranslations.new
      translation_a.add(:es, 'foobybar')
      expect(translation_a.to_send.size).to eq(1)

      translation_b = Localeapp::MissingTranslations.new
      translation_b.add(:en, 'foobybar')
      expect(translation_a.to_send.size).to eq(0)
    end
  end

  it "can send the same key twice when cache_missing_translations is false" do
    with_configuration(:cache_missing_translations => false) do
      translation_a = Localeapp::MissingTranslations.new
      translation_a.add(:es, 'foobybar')
      expect(translation_a.to_send.size).to eq(1)

      translation_b = Localeapp::MissingTranslations.new
      translation_b.add(:en, 'foobybar')
      expect(translation_a.to_send.size).to eq(1)
    end
  end
end

describe Localeapp::MissingTranslations, "#reject_blacklisted" do
  let(:translations) { Localeapp::MissingTranslations.new }
  let(:count) { Proc.new { translations.to_send.count } }

  before do
    translations.add(:en, 'feline.lion')
    translations.add(:en, 'feline.tiger')
    translations.add(:en, 'bird.eagle')
    translations.add(:de, 'crow', nil, {:scope => 'bird'})
    translations.add(:fr, 'feline.lion')
    translations.add(:fr, 'reptile.lizard')
  end

  it "removes translations whose key matches the blacklisted_keys_pattern" do
    with_configuration(:blacklisted_keys_pattern => /^feline/) do
      expect { translations.reject_blacklisted }.to change(count, :call).by(-3)
    end
  end

  it "removes translations whose scope matches the blacklisted_keys_pattern" do
    with_configuration(:blacklisted_keys_pattern => /^bird\./) do
      expect { translations.reject_blacklisted }.to change(count, :call).by(-2)
    end
  end

  it "does nothing when blacklisted_keys_pattern is nil" do
    with_configuration do
      expect { translations.reject_blacklisted }.to_not change(count, :call)
    end
  end

  it "does nothing when blacklisted_keys_pattern does not match anything" do
    with_configuration(:blacklisted_keys_pattern => /^canine/) do
      expect { translations.reject_blacklisted }.to_not change(count, :call)
    end
  end
end
