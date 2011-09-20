require 'spec_helper'

describe Localeapp::Configuration do
  let(:configuration) { Localeapp::Configuration.new }

  it "sets the host by default" do
    configuration.host.should == 'api.localeapp.com'
  end

  it "allows the host to be overwritten" do
    expect { configuration.host = 'test.host' }.to change(configuration, :host).to('test.host')
  end

  it "sets secure to true by default" do
    configuration.secure.should == true
  end

  it "allows secure setting to be overridden" do
    expect { configuration.secure = false }.to change(configuration, :secure).to(false)
  end

  it "sets ssl_verify to false by default" do
    configuration.ssl_verify.should == false
  end

  it "allows ssl_verify setting to be overridden" do
    expect { configuration.ssl_verify = true }.to change(configuration, :ssl_verify).to(true)
  end

  it "sets ssl_ca_file to nil by default" do
    configuration.ssl_ca_file.should == nil
  end

  it "allows ssl_ca_file setting to be overridden" do
    expect { configuration.ssl_ca_file = '/foo/bar' }.to change(configuration, :ssl_ca_file).to('/foo/bar')
  end

  it "includes http_auth_username defaulting to nil" do
    configuration.http_auth_username.should == nil
    configuration.http_auth_username = "test"
    configuration.http_auth_username.should == "test"
  end

  it "includes http_auth_password defaulting to nil" do
    configuration.http_auth_password.should == nil
    configuration.http_auth_password = "test"
    configuration.http_auth_password.should == "test"
  end

  it "includes translation_data_directory defaulting to config/locales" do
    configuration.translation_data_directory.should == File.join("config", "locales")
    configuration.translation_data_directory = "test"
    configuration.translation_data_directory.should == "test"
  end

  context "enabled_sending_environments" do
    it "is only development by default" do
      configuration.sending_environments.should == ['development']
    end
  end

  context "enabled_reloading_environments" do
    it "is only development by default" do
      configuration.reloading_environments.should == ['development']
    end
  end

  context "enabled_polling_environments" do
    it "is only development by default" do
      configuration.polling_environments.should == ['development']
    end
  end

  context "disabled_sending_environments" do
    it "sets deprecated_environment_config_used flag to true" do
      configuration.disabled_sending_environments = %(foo bar)
      configuration.deprecated_environment_config_used?.should be_true
    end

    it "does not include development by default" do
      configuration.environment_name = 'development'
      configuration.sending_disabled?.should be_false
    end

    it "include cucumber by default" do
      configuration.environment_name = 'cucumber'
      configuration.sending_disabled?.should be_true
    end

    it "include test by default" do
      configuration.environment_name = 'test'
      configuration.sending_disabled?.should be_true
    end

    it "include production by default" do
      configuration.environment_name = 'production'
      configuration.sending_disabled?.should be_true
    end
  end

  context "disabled_reloading_environments" do
    it "sets deprecated_environment_config_used flag to true" do
      configuration.disabled_reloading_environments = %(foo bar)
      configuration.deprecated_environment_config_used?.should be_true
    end

    it "does not include development by default" do
      configuration.environment_name = 'development'
      configuration.reloading_disabled?.should be_false
    end

    it "include cucumber by default" do
      configuration.environment_name = 'cucumber'
      configuration.reloading_disabled?.should be_true
    end

    it "include test by default" do
      configuration.environment_name = 'test'
      configuration.reloading_disabled?.should be_true
    end

    it "include production by default" do
      configuration.environment_name = 'production'
      configuration.reloading_disabled?.should be_true
    end
  end
  
  context "disabled_polling_environments" do
    it "sets deprecated_environment_config_used flag to true" do
      configuration.disabled_polling_environments = %(foo bar)
      configuration.deprecated_environment_config_used?.should be_true
    end

    it "does not include development by default" do
      configuration.environment_name = 'development'
      configuration.polling_disabled?.should be_false
    end

    it "include cucumber by default" do
      configuration.environment_name = 'cucumber'
      configuration.polling_disabled?.should be_true
    end

    it "include test by default" do
      configuration.environment_name = 'test'
      configuration.polling_disabled?.should be_true
    end

    it "include production by default" do
      configuration.environment_name = 'production'
      configuration.polling_disabled?.should be_true
    end
  end

  describe "polling_disabled?" do
    context "deprecated syntax used" do
      it "is true when environment is disabled" do
        configuration.disabled_polling_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should be_polling_disabled
      end

      it "is false when environment is not disabled" do
        configuration.disabled_polling_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should_not be_polling_disabled
      end
    end

    context "new syntax used" do
      it "is true when environment is not enabled" do
        configuration.polling_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should be_polling_disabled
      end

      it "is false when environment is enabled" do
        configuration.polling_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should_not be_polling_disabled
      end
    end
  end

  describe "reloading_disabled?" do
    context "deprecated syntax used" do
      it "is true when environment is disabled" do
        configuration.disabled_reloading_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should be_reloading_disabled
      end

      it "is false when environment is not disabled" do
        configuration.disabled_reloading_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should_not be_reloading_disabled
      end
    end

    context "new syntax used" do
      it "is true when environment is not enabled" do
        configuration.reloading_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should be_reloading_disabled
      end

      it "is false when environment is enabled" do
        configuration.reloading_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should_not be_reloading_disabled
      end
    end
  end

  describe "sending_disabled?" do
    context "deprecated syntax used" do
      it "is true when environment is disabled" do
        configuration.disabled_sending_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should be_sending_disabled
      end

      it "is false when environment is not disabled" do
        configuration.disabled_sending_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should_not be_sending_disabled
      end
    end

    context "new syntax used" do
      it "is true when environment is not enabled" do
        configuration.sending_environments = %(foo)
        configuration.environment_name = 'bar'
        configuration.should be_sending_disabled
      end

      it "is false when environment is enabled" do
        configuration.sending_environments = %(foo)
        configuration.environment_name = 'foo'
        configuration.should_not be_sending_disabled
      end
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
end
CONTENT
    File.should_receive(:open).with(path, 'w+').and_yield(file)
    configuration.write_initial(path)
  end
end
