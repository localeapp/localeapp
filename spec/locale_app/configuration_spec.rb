require 'spec_helper'

describe LocaleApp::Configuration do
  before(:each) do
    @configuration = LocaleApp::Configuration.new
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
