require 'spec_helper'

describe LocaleApp::Configuration do
  before(:each) do
    @configuration = LocaleApp::Configuration.new
  end

  it "sets the host by default" do
    @configuration.host.should == 'api.localeapp.com'
  end

  it "allows the host to be overwritten" do
    expect { @configuration.host = 'test.host' }.to change(@configuration, :host).to('test.host')
  end

  it "includes http_auth_username defaulting to nil" do
    @configuration.http_auth_username.should == nil
    @configuration.http_auth_username = "test"
    @configuration.http_auth_username.should == "test"
  end

  it "includes http_auth_password defaulting to nil" do
    @configuration.http_auth_password.should == nil
    @configuration.http_auth_password = "test"
    @configuration.http_auth_password.should == "test"
  end

  it "includes translation_data_directory defaulting to config/locales" do
    @configuration.translation_data_directory.should == File.join("config", "locales")
    @configuration.translation_data_directory = "test"
    @configuration.translation_data_directory.should == "test"
  end
end

describe LocaleApp::Configuration, "#write_initial(path)" do
  it "creates a configuration file containing just the api key at the given path" do
    configuration = LocaleApp::Configuration.new
    configuration.api_key = "APIKEY"
    path = 'test_path'
    file = stub('file')
    file.should_receive(:write).with <<-CONTENT
require 'locale_app/rails'

LocaleApp.configure do |config|
  config.api_key = 'APIKEY'
end
CONTENT
    File.should_receive(:open).with(path, 'w+').and_yield(file)
    configuration.write_initial(path)
  end
end
