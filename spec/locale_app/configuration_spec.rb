require 'spec_helper'

describe LocaleApp::Configuration do
  before(:each) do
    @configuration = LocaleApp::Configuration.new
  end

  it "includes http_auth_username" do
    @configuration.http_auth_username = "test"
    @configuration.http_auth_username.should == "test"
  end

  it "includes http_auth_password" do
    @configuration.http_auth_password = "test"
    @configuration.http_auth_password.should == "test"
  end
end
