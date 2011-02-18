require 'spec_helper'

describe LocaleApp::Poller, "#translation_resource_url" do
  it "is constructed from the configuration host, port and api key" do
    with_configuration(:host => 'test.host', :port => 1234, :api_key => 'KEY') do
      LocaleApp::Poller.new.translation_resource_url.should == "http://test.host:1234/translations.yml?api_key=KEY"
    end
  end

  it "includes http auth if if configuration" do
    with_configuration(:host => 'test.host', :port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar', :api_key => 'KEY') do
      LocaleApp::Poller.new.translation_resource_url.should == "http://foo:bar@test.host:1234/translations.yml?api_key=KEY"
    end
  end
end

describe LocaleApp::Poller, "#translation_resource_status_url" do
  it "is constructed from the configuration host, port and api key" do
    with_configuration(:host => 'test.host', :port => 1234, :api_key => 'KEY') do
      LocaleApp::Poller.new.translation_resource_status_url.should == "http://test.host:1234/translations/updated_at?api_key=KEY"
    end
  end

  it "includes http auth if if configuration" do
    with_configuration(:host => 'test.host', :port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar', :api_key => 'KEY') do
      LocaleApp::Poller.new.translation_resource_status_url.should == "http://foo:bar@test.host:1234/translations/updated_at?api_key=KEY"
    end
  end
end
