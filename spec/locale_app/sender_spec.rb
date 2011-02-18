require 'spec_helper'

describe LocaleApp::Sender, "#translation_resource_url" do
  it "is constructed from the configuration host and port" do
    with_configuration(:host => 'test.host', :port => 1234) do
      LocaleApp::Sender.new.translation_resource_url.should == "http://test.host:1234/translations"
    end
  end

  it "includes http auth if if configuration" do
    with_configuration(:host => 'test.host', :port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar') do
      LocaleApp::Sender.new.translation_resource_url.should == "http://foo:bar@test.host:1234/translations"
    end
  end
end

describe LocaleApp::Sender, "#post_translation(locale, key, options, value = nil)" do
  before(:each) do
    @sender = LocaleApp::Sender.new
    @url = 'http://test.host/translations'
    @sender.stub!(:translation_resource_url).and_return(@url)
    LocaleApp.configuration.api_key = "API_KEY"
  end

  it "posts the missing translation data to the backend" do
    data = {
      :api_key => LocaleApp.configuration.api_key,
      :translation => {
        :key => "test.key",
        :locale => "en",
        :substitutions => ['foo', 'bar'],
        :description => "test content"
      }
    }
    RestClient.should_receive(:post).with(@url, data.to_json, :content_type => :json, :accept => :json )
    @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar' }, 'test content')
  end

  it "does nothing if the current environment is in disabled_environments" do
    with_configuration(:disabled_environments => [:spec_test], :environment_name => :spec_test) do
      RestClient.should_not_receive(:post)
      @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar' }, 'test content')
    end
  end
end
