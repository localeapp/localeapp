require 'spec_helper'

describe Localeapp::Configuration do
  let(:configuration) { Localeapp::Configuration.new }

  it "sets the host by default" do
    expect(configuration.host).to eq('api.localeapp.com')
  end

  it "allows the host to be overwritten" do
    expect { configuration.host = 'test.host' }.to change(configuration, :host).to('test.host')
  end

  it "sets proxy to nil by default" do
    expect(configuration.proxy).to eq(nil)
  end

  it "allows proxy setting to be overridden" do
    expect { configuration.proxy = 'http://localhost:8888' }.to change(configuration, :proxy).to('http://localhost:8888')
  end

  it "sets timeout to 60 by default" do
    expect(configuration.timeout).to eq(60)
  end

  it "allows timeout setting to be overridden" do
    expect { configuration.timeout = 120 }.to change(configuration, :timeout).to(120)
  end

  it "sets secure to true by default" do
    expect(configuration.secure).to eq(true)
  end

  it "allows secure setting to be overridden" do
    expect { configuration.secure = false }.to change(configuration, :secure).to(false)
  end

  it "sets ssl_verify to false by default" do
    expect(configuration.ssl_verify).to eq(false)
  end

  it "sets ssl_version to 'SSLv23' by default" do
    expect(configuration.ssl_version).to eq('SSLv23')
  end

  it "allows ssl_verify setting to be overridden" do
    expect { configuration.ssl_verify = true }.to change(configuration, :ssl_verify).to(true)
  end

  it "sets ssl_ca_file to nil by default" do
    expect(configuration.ssl_ca_file).to eq(nil)
  end

  it "allows ssl_ca_file setting to be overridden" do
    expect { configuration.ssl_ca_file = '/foo/bar' }.to change(configuration, :ssl_ca_file).to('/foo/bar')
  end

  it "includes http_auth_username defaulting to nil" do
    expect(configuration.http_auth_username).to eq(nil)
    configuration.http_auth_username = "test"
    expect(configuration.http_auth_username).to eq("test")
  end

  it "includes http_auth_password defaulting to nil" do
    expect(configuration.http_auth_password).to eq(nil)
    configuration.http_auth_password = "test"
    expect(configuration.http_auth_password).to eq("test")
  end

  it "includes translation_data_directory defaulting to config/locales" do
    expect(configuration.translation_data_directory).to eq(File.join("config", "locales"))
    configuration.translation_data_directory = "test"
    expect(configuration.translation_data_directory).to eq("test")
  end

  it "sets the daemon_pid_file by default" do
    expect(configuration.daemon_pid_file).to eq('tmp/pids/localeapp.pid')
  end

  it "allows the daemon_pid_file to be overwritten" do
    expect { configuration.daemon_pid_file = 'foo/la.pid' }.to change(configuration, :daemon_pid_file).to('foo/la.pid')
  end

  it "sets the daemon_log_file by default" do
    expect(configuration.daemon_log_file).to eq('log/localeapp_daemon.log')
  end

  it "allows the daemon_log_file to be overwritten" do
    expect { configuration.daemon_log_file = 'log/la.log' }.to change(configuration, :daemon_log_file).to('log/la.log')
  end

  it "sets the sending_blacklist by default" do
    expect(configuration.blacklisted_keys_pattern).to be_nil
  end

  context "enabled_sending_environments" do
    it "is only development by default" do
      expect(configuration.sending_environments).to eq(['development'])
    end
  end

  context "enabled_reloading_environments" do
    it "is only development by default" do
      expect(configuration.reloading_environments).to eq(['development'])
    end
  end

  context "enabled_polling_environments" do
    it "is only development by default" do
      expect(configuration.polling_environments).to eq(['development'])
    end
  end

  describe "polling_disabled?" do
    it "is true when environment is not enabled" do
      configuration.polling_environments = %w(foo)
      configuration.environment_name = 'bar'
      expect(configuration).to be_polling_disabled
    end

    it "is false when environment is enabled" do
      configuration.polling_environments = %w(foo)
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_polling_disabled
    end

    it "supports symbols in list of environments" do
      configuration.polling_environments = [:foo]
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_polling_disabled
    end
  end

  describe "reloading_disabled?" do
    it "is true when environment is not enabled" do
      configuration.reloading_environments = %w(foo)
      configuration.environment_name = 'bar'
      expect(configuration).to be_reloading_disabled
    end

    it "is false when environment is enabled" do
      configuration.reloading_environments = %w(foo)
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_reloading_disabled
    end

    it "supports symbols in list of environments" do
      configuration.reloading_environments = [:foo]
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_reloading_disabled
    end
  end

  describe "sending_disabled?" do
    it "is true when environment is not enabled" do
      configuration.sending_environments = %w(foo)
      configuration.environment_name = 'bar'
      expect(configuration).to be_sending_disabled
    end

    it "is false when environment is enabled" do
      configuration.sending_environments = %w(foo)
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_sending_disabled
    end

    it "supports symbols in the list of environments" do
      configuration.sending_environments = [:foo]
      configuration.environment_name = 'foo'
      expect(configuration).not_to be_sending_disabled
    end
  end

  describe "#has_api_key?" do

    context "when an api_key is defined" do
      it "returns true" do
        configuration.api_key = '0123456789abcdef'
        expect(configuration.has_api_key?).to be true
      end
    end

    context "with no api_key provided" do
      it "returns false" do
        expect(configuration.has_api_key?).to be false
      end
    end

  end

end
