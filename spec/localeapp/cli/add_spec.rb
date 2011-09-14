require 'spec_helper'

describe Localeapp::CLI::Add, "#execute(key, *translations)" do
  def do_action
    @command.execute('test.key', 'en:test en', 'es:test es')
  end

  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Add.new(@output)
  end

  it "adds the translations to missing_translations" do
    with_configuration do
      Localeapp.sender.stub!(:post_missing_translations)
      do_action
    end
    en_missing = Localeapp.missing_translations['en']
    en_missing.size.should == 1
    en_missing['test.key'].locale.should == 'en'
    en_missing['test.key'].description.should == 'test en'
    es_missing = Localeapp.missing_translations['es']
    es_missing.size.should == 1
    es_missing['test.key'].locale.should == 'es'
    es_missing['test.key'].description.should == 'test es'
  end

  it "tells the sender to send the missing translations" do
    with_configuration do
      Localeapp.sender.should_receive(:post_missing_translations)
      do_action
    end
  end
end
