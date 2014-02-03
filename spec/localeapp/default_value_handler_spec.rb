require 'spec_helper'

class Klass
  include I18n::Backend::Base
end

class I18nWithFallbacks < I18n::Backend::Simple
  include I18n::Backend::Fallbacks
end

describe I18n::Backend::Base, '#default' do
  let(:klass) { Klass.new }

  def allow_sending
    with_configuration(:sending_environments => ['my_env'], :environment_name => 'my_env' ) do
      yield
    end
  end

  describe "when subject is a String" do
    it "adds translations to missing translations to send to Locale" do
      allow_sending do
        Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', 'bar', :baz => 'bam')
        klass.default(:en, 'foo', 'bar', :baz => 'bam')
      end
    end

    it "strips the subject when the translation is not in the default locale" do
      allow_sending do
        Localeapp.missing_translations.should_receive(:add).with(:fr, 'foo', nil, :baz => 'bam')
        klass.default(:fr, 'foo', 'bar', :baz => 'bam')
      end
    end

    it "adds translations to missing translations when using a string as the locale" do
      allow_sending do
        Localeapp.missing_translations.should_receive(:add).with('en', 'foo', 'bar', :baz => 'bam')
        klass.default('en', 'foo', 'bar', :baz => 'bam')
      end
    end
  end

  describe "when subject is an Array" do

    describe "and there is a text inside the array" do
      it "add translations to missing translations to send to Locale" do
        allow_sending do
          Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', 'correct default', :baz => 'bam')
          klass.default(:en, 'foo', [:missing, 'correct default'], :baz => 'bam')
        end
      end
    end

    describe "and there is not a text inside the array" do
      it "doesn't send anything to Locale" do
        allow_sending do
          Localeapp.missing_translations.should_not_receive(:add)
          I18n.stub(:translate) do |subject, _|
            subject == :not_missing ? "not missing" : nil
          end
          klass.default(:en, 'foo', [:missing, :not_missing], :baz => 'bam')
        end
      end
    end
  end

  describe "when subject is a Symbol" do
    it "doesn't send anything to Locale" do
      allow_sending do
        Localeapp.missing_translations.should_not_receive(:add)
        klass.default(:en, 'foo', :other_key, :baz => 'bam')
      end
    end
  end

  it "records missing translations when fallbacks are enabled" do
    i18n = I18nWithFallbacks.new

    with_configuration(:sending_environments => ['my_env'], :environment_name => 'my_env' ) do
      Localeapp.missing_translations.should_receive(:add).with(:en, 'my.object', 'my default', {:default => 'my default'})
      i18n.translate(:en, 'my.object', :default => 'my default')
    end
  end
end
