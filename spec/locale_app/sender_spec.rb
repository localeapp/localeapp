require 'spec_helper'

describe LocaleApp::Sender, "#post_translation(locale, key, options, value = nil)" do
  before(:each) do
    @sender = LocaleApp::Sender.new
    LocaleApp.configuration.api_key = "API_KEY"
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
    RestClient.should_receive(:post).with(@sender.translations_url, data.to_json, :content_type => :json, :accept => :json )
    @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar' }, 'test content')
  end
end