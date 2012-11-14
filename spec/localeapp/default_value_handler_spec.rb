require 'spec_helper'

class Klass
  include I18n::Backend::Base
end

describe I18n::Backend::Base, '#default' do
  let(:klass) { Klass.new }

  it "adds translations to missing translations to send to Locale" do
    with_configuration(:sending_environments => ['my_env'], :environment_name => 'my_env' ) do
      Localeapp.missing_translations.should_receive(:add).with(:en, 'foo', 'bar', :baz => 'bam')
      klass.default(:en, 'foo', 'bar', :baz => 'bam')
    end
  end

  describe "when subject is an array" do
    it "doesn't send anything" do
      with_configuration(:sending_environments => ['my_env'], :environment_name => 'my_env' ) do
        Localeapp.missing_translations.should_not_receive(:add).with(:en, 'foo', 'not missing', :baz => 'bam')
        I18n.stub!(:translate) do |subject, _|
          if subject == :not_missing
            "not missing"
          else
            nil
          end
        end
        klass.default(:en, 'foo', [:missing, :not_missing], :baz => 'bam')
      end
    end
  end
end
