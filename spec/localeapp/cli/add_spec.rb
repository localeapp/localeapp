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
      allow(Localeapp.sender).to receive(:post_missing_translations)
      do_action
    end
    en_missing = Localeapp.missing_translations['en']
    expect(en_missing.size).to eq(1)
    expect(en_missing['test.key'].locale).to eq('en')
    expect(en_missing['test.key'].description).to eq('test en')
    es_missing = Localeapp.missing_translations['es']
    expect(es_missing.size).to eq(1)
    expect(es_missing['test.key'].locale).to eq('es')
    expect(es_missing['test.key'].description).to eq('test es')
  end

  it "ignores badly formed arguments" do
    with_configuration do
      allow(Localeapp.sender).to receive(:post_missing_translations)
      do_action('test.key', ["en:this is fine", "esbad"])
    end
    expect(Localeapp.missing_translations['en'].size).to eq(1)
    expect(Localeapp.missing_translations['es'].size).to eq(0)
    expect(Localeapp.missing_translations['esbad'].size).to eq(0)
    expect(@output.string).to include("Ignoring bad translation esbad")
    expect(@output.string).to include("format should be <locale>:<translation content>")
  end

  it "tells the sender to send the missing translations" do
    with_configuration do
      expect(Localeapp.sender).to receive(:post_missing_translations)
      do_action
    end
  end
end
