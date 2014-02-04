require 'spec_helper'

describe Localeapp::CLI::Add, "#execute(key, *translations)" do
  def do_action(key = 'test.key', args = nil)
    args ||= ['en:test en', 'es:test es']
    @command.execute(key, *args)
  end

  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Add.new(:output => @output)
  end

  it "adds the translations to missing_translations" do
    with_configuration do
      Localeapp.sender.stub(:post_missing_translations)
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

  it "ignores badly formed arguments" do
    with_configuration do
      Localeapp.sender.stub(:post_missing_translations)
      do_action('test.key', ["en:this is fine", "esbad"])
    end
    Localeapp.missing_translations['en'].size.should == 1
    Localeapp.missing_translations['es'].size.should == 0
    Localeapp.missing_translations['esbad'].size.should == 0
    @output.string.should include("Ignoring bad translation esbad")
    @output.string.should include("format should be <locale>:<translation content>")
  end

  it "tells the sender to send the missing translations" do
    with_configuration do
      Localeapp.sender.should_receive(:post_missing_translations)
      do_action
    end
  end
end
