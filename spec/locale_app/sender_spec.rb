require 'spec_helper'

describe LocaleApp::Sender, "#post_translation(locale, key, options, value = nil)" do
  before(:each) do
    with_configuration(:api_key => "TEST_KEY") do
      @sender = LocaleApp::Sender.new
    end
  end

  it "posts the missing translation data to the backend" do
    data = {
      :translation => {
        :key => "test.key",
        :locale => "en",
        :substitutions => ['foo', 'bar'],
        :description => "test content"
      }
    }
    # have to stub RestClient here as FakeWeb doesn't support looking at the post body yet
    RestClient.should_receive(:post).with(@sender.translations_url, data.to_json).and_return(double('response', :code => 200))
    @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar' }, 'test content')
  end
end

describe LocaleApp::Sender, "#post_missing_translations" do
  before(:each) do
    with_configuration(:api_key => 'TEST_KEY') do
      @sender = LocaleApp::Sender.new
    end
  end

  it "sends the missing translation data to the API" do
    missing_to_send = [
      { :key => "test.key", :locale => "en" },
      { :key => "test.key2", :locale => "en" }
    ]
    LocaleApp.missing_translations.should_receive(:to_send).and_return(missing_to_send)
    data = { :translations => missing_to_send }
    # have to stub RestClient here as FakeWeb doesn't support looking at the post body yet
    RestClient.should_receive(:post).with(@sender.missing_translations_url, data.to_json).and_return(double('response', :code => 200))
    @sender.post_missing_translations
  end
end
