require 'spec_helper'

class TestRoutes
  include LocaleApp::Routes
end
  
describe LocaleApp::Routes, '#project_url' do
  before(:each) do
    @routes = TestRoutes.new
  end

  it "is constructed from the configuration host and port" do
    with_configuration(:host => 'test.host', :port => 1234, :api_key => 'API_KEY') do
      @routes.project_url.should == "http://test.host:1234/api/projects/API_KEY"
    end
  end

  it "includes http auth if in configuration" do
    with_configuration(:host => 'test.host', :port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar', :api_key => 'API_KEY') do
      @routes.project_url.should == "http://foo:bar@test.host:1234/api/projects/API_KEY"
    end
  end
end

describe LocaleApp::Routes, "#translations_url" do
  before(:each) do
    @routes = TestRoutes.new
  end

  it "it extends the project_url" do
    with_configuration(:host => 'test.host', :port => 1234, :api_key => 'API_KEY') do
      @routes.translations_url.should == "http://test.host:1234/api/projects/API_KEY/translations"
    end
  end
end