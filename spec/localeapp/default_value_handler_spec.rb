require 'spec_helper'

class Klass
  include I18n::Backend::Base
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
  end

  describe "when subject is an Array" do
    it "doesn't send anything to Locale" do
      allow_sending do
        Localeapp.missing_translations.should_not_receive(:add)
        I18n.stub!(:translate) do |subject, _|
          subject == :not_missing ? "not missing" : nil
        end
        klass.default(:en, 'foo', [:missing, :not_missing], :baz => 'bam')
      end
    end
  end
end
