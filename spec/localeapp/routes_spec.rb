require 'spec_helper'

class TestRoutes
  include Localeapp::Routes
end
  
describe Localeapp::Routes do
  before(:each) do
    @routes = TestRoutes.new
    @config = {:host => 'test.host', :api_key => 'API_KEY'}
  end

  describe "#project_endpoint(options = {})" do
    it "returns :get and the project url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:project_url).with(options).and_return('url')
        expect(@routes.project_endpoint(options)).to eq([:get, 'url'])
      end
    end
  end

  describe '#project_url' do
    it "is constructed from the configuration host, port and secure and defaults to json" do
      with_configuration(@config.merge(:port => 1234, :secure => false)) do
        expect(@routes.project_url).to eq("http://test.host:1234/v1/projects/API_KEY.json")
      end
    end

    it "includes http auth if in configuration" do
      with_configuration(@config.merge(:port => 1234, :http_auth_username => 'foo', :http_auth_password => 'bar')) do
        expect(@routes.project_url).to eq("https://foo:bar@test.host:1234/v1/projects/API_KEY.json")
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        expect(@routes.project_url(:format => :yml)).to eq('https://test.host/v1/projects/API_KEY.yml')
      end
    end
  end

  describe "#translations_url" do
    it "it extends the project_url and defaults to yml" do
      with_configuration(@config) do
        expect(@routes.translations_url).to eq("https://test.host/v1/projects/API_KEY/translations.yml")
      end
    end

    it "adds query parameters on to the url" do
      with_configuration(@config) do
        url = @routes.translations_url(:query => {:updated_at => '2011-04-19', :foo => :bar})
        expect(url).to match(/\?.*updated_at=2011-04-19/)
        expect(url).to match(/\?.*foo=bar/)
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        expect(@routes.translations_url(:format => :json)).to eq('https://test.host/v1/projects/API_KEY/translations.json')
      end
    end
  end

  describe "#translations_endpoint(options = {})" do
    it "returns :get and the translations url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:translations_url).with(options).and_return('url')
        expect(@routes.translations_endpoint(options)).to eq([:get, 'url'])
      end
    end
  end

  describe "#create_translation_endpoint(options = {})" do
    it "returns :post and the translation url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:translations_url).with(options).and_return('url')
        expect(@routes.create_translation_endpoint(options)).to eq([:post, 'url'])
      end
    end
  end

  describe "#remove_endpoint(options = {})" do
    it "returns :delete and the remove url for the options" do
      with_configuration(@config) do
        options = { :key => 'foo.bar' }
        expect(@routes).to receive(:remove_url).with(options).and_return('url')
        expect(@routes.remove_endpoint(options)).to eq([:delete, 'url'])
      end
    end
  end

  describe "#remove_url(options = {})" do
    it "it extends the project_url and includes the escaped key name" do
      with_configuration(@config) do
        expect(@routes.remove_url(:key => 'test.key')).to eq("https://test.host/v1/projects/API_KEY/translations/test%2Ekey")
      end
    end

    it "URL encodes the key name" do
      with_configuration @config do
        expect(@routes.remove_url key: "some key").to include "some+key"
      end
    end
  end

  describe "#rename_endpoint(options = {})" do
    it "returns :post and the rename url for the options" do
      with_configuration(@config) do
        options = { :current_name => 'foo.bar' }
        expect(@routes).to receive(:rename_url).with(options).and_return('url')
        expect(@routes.rename_endpoint(options)).to eq([:post, 'url'])
      end
    end
  end

  describe "#rename_url(options = {})" do
    it "it extends the project_url and includes the escaped key name" do
      with_configuration(@config) do
        expect(@routes.rename_url(:current_name => 'test.key')).to eq("https://test.host/v1/projects/API_KEY/translations/test%2Ekey/rename")
      end
    end
  end

  describe "#copy_endpoint(options = {})" do
    it "returns :post and the copy url for the options" do
      with_configuration(@config) do
        options = { :source_name => "foo.bar" }
        expect(@routes).to receive(:copy_url).with(options).and_return("url")
        expect(@routes.copy_endpoint(options)).to eq([:post, "url"])
      end
    end
  end

  describe "#copy_url(options = {})" do
    it "extends the project_url and includes the escaped key name" do
      with_configuration(@config) do
        expect(@routes.copy_url(:source_name => "test.key")).to eq("https://test.host/v1/projects/API_KEY/translations/test%2Ekey/copy")
      end
    end
  end

  describe "#export_url" do
    it "it extends the project_url and defaults to yml" do
      with_configuration(@config) do
        expect(@routes.export_url).to eq("https://test.host/v1/projects/API_KEY/translations/all.yml")
      end
    end

    it "adds query parameters on to the url" do
      with_configuration(@config) do
        url = @routes.export_url(:query => {:updated_at => '2011-04-19', :foo => :bar})
        expect(url).to match(/\?.*updated_at=2011-04-19/)
        expect(url).to match(/\?.*foo=bar/)
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        expect(@routes.export_url(:format => :json)).to eq('https://test.host/v1/projects/API_KEY/translations/all.json')
      end
    end
  end

  describe "#export_endpoint(options = {})" do
    it "returns :get and the export url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:export_url).with(options).and_return('url')
        expect(@routes.export_endpoint(options)).to eq([:get, 'url'])
      end
    end
  end

  describe "#missing_translations_endpoint(options = {})" do
    it "returns :post and the missing_translations url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:missing_translations_url).with(options).and_return('url')
        expect(@routes.missing_translations_endpoint(options)).to eq([:post, 'url'])
      end
    end
  end

  describe "#missing_translations_url" do
    it "it extends the project_url and defaults to json" do
      with_configuration(@config) do
        expect(@routes.missing_translations_url).to eq("https://test.host/v1/projects/API_KEY/translations/missing.json")
      end
    end

    it "adds query parameters on to the url" do
      with_configuration(@config) do
        url = @routes.missing_translations_url(:query => {:updated_at => '2011-04-19', :foo => :bar})
        expect(url).to match(/\?.*updated_at=2011-04-19/)
        expect(url).to match(/\?.*foo=bar/)
      end
    end

    it "can be changed to another content type" do
      with_configuration(@config) do
        expect(@routes.missing_translations_url(:format => :yml)).to eq('https://test.host/v1/projects/API_KEY/translations/missing.yml')
      end
    end
  end

  describe "#import_url" do
    it "appends 'import to the project url" do
      with_configuration(@config) do
        expect(@routes.import_url).to eq('https://test.host/v1/projects/API_KEY/import/')
      end
    end
  end

  describe "#import_endpoint(options = {})" do
    it "returns :post and the import url for the options" do
      with_configuration(@config) do
        options = { :foo => :bar }
        expect(@routes).to receive(:import_url).with(options).and_return('url')
        expect(@routes.import_endpoint(options)).to eq([:post, 'url'])
      end
    end
  end
end
