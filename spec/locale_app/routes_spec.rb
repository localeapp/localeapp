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
    it "is constructed from the configuration host and port and defaults to json" do
      with_configuration(@config.merge(:port => 1234)) do
        @routes.project_url.should == "http://test.host:1234/projects/API_KEY.json"
      end
    end

    it "includes http auth if in configuration" do
      with_configuration(@config.merge(:port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar')) do
        @routes.project_url.should == "http://foo:bar@test.host:1234/projects/API_KEY.json"
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        @routes.project_url(:format => :yml).should == 'http://test.host/projects/API_KEY.yml'
      end
    end
  end

  describe "#translations_url" do
    it "it extends the project_url and defaults to json" do
      with_configuration(@config) do
        @routes.translations_url.should == "http://test.host/projects/API_KEY/translations.json"
      end
    end

    it "adds query parameters on to the url" do
      with_configuration(@config) do
        @routes.translations_url(:query => {:updated_at => '2011-04-19', :foo => :bar}).should == "http://test.host/projects/API_KEY/translations.json?updated_at=2011-04-19&foo=bar"
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        @routes.translations_url(:format => :yml).should == 'http://test.host/projects/API_KEY/translations.yml'
      end
    end
  end

  describe "#import_url" do
    it "appends 'import to the project url" do
      with_configuration(@config) do
        @routes.import_url.should == 'http://test.host/projects/API_KEY/import/'
      end
    end
  end
end
