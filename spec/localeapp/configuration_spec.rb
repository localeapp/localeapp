require 'spec_helper'

describe Localeapp::Configuration do
  before(:each) do
    @configuration = Localeapp::Configuration.new
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

  context "disabled_sending_environments" do
    it "does not include development by default" do
      @configuration.environment_name = 'development'
      @configuration.sending_disabled?.should be_false
    end

    it "include cucumber by default" do
      @configuration.environment_name = 'cucumber'
      @configuration.sending_disabled?.should be_true
    end

    it "include test by default" do
      @configuration.environment_name = 'test'
      @configuration.sending_disabled?.should be_true
    end

    it "include production by default" do
      @configuration.environment_name = 'production'
      @configuration.sending_disabled?.should be_true
    end
  end

  context "disabled_reloading_environments" do
    it "does not include development by default" do
      @configuration.environment_name = 'development'
      @configuration.reloading_disabled?.should be_false
    end

    it "include cucumber by default" do
      @configuration.environment_name = 'cucumber'
      @configuration.reloading_disabled?.should be_true
    end

    it "include test by default" do
      @configuration.environment_name = 'test'
      @configuration.reloading_disabled?.should be_true
    end

    it "include production by default" do
      @configuration.environment_name = 'production'
      @configuration.reloading_disabled?.should be_true
    end
  end
  
  context "disabled_polling_environments" do
    it "does not include development by default" do
      @configuration.environment_name = 'development'
      @configuration.polling_disabled?.should be_false
    end

    it "include cucumber by default" do
      @configuration.environment_name = 'cucumber'
      @configuration.polling_disabled?.should be_true
    end

    it "include test by default" do
      @configuration.environment_name = 'test'
      @configuration.polling_disabled?.should be_true
    end

    it "include production by default" do
      @configuration.environment_name = 'production'
      @configuration.polling_disabled?.should be_true
    end
  end
end

describe Localeapp::Configuration, "#write_initial(path)" do
  it "creates a configuration file containing just the api key at the given path" do
    configuration = Localeapp::Configuration.new
    configuration.api_key = "APIKEY"
    path = 'test_path'
    file = stub('file')
    file.should_receive(:write).with <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = 'APIKEY'
  config.host = 'api.localeapp.com'
  config.port = 80
end
CONTENT
    File.should_receive(:open).with(path, 'w+').and_yield(file)
    configuration.write_initial(path)
  end
end
