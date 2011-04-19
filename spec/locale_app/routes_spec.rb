require 'spec_helper'

class TestRoutes
  include LocaleApp::Routes
end
  
describe LocaleApp::Routes do
  before(:each) do
    @routes = TestRoutes.new
    @config = {:host => 'test.host', :api_key => 'API_KEY'}
  end

  describe '#project_url' do
    it "is constructed from the configuration host and port" do
      with_configuration(@config.merge(:port => 1234)) do
        @routes.project_url.should == "http://test.host:1234/projects/API_KEY"
      end
    end

    it "includes http auth if in configuration" do
      with_configuration(@config.merge(:port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar')) do
        @routes.project_url.should == "http://foo:bar@test.host:1234/projects/API_KEY"
      end
    end
  end

  describe "#translations_url" do
    it "it extends the project_url" do
      with_configuration(@config) do
        @routes.translations_url.should == "http://test.host/projects/API_KEY/translations"
      end
    end

    it "adds query parameters on to the url" do
      with_configuration(@config) do
        @routes.translations_url(:query => {:updated_at => '2011-04-19', :foo => :bar}).should == "http://test.host/projects/API_KEY/translations?updated_at=2011-04-19&foo=bar"
      end
    end
  end

end