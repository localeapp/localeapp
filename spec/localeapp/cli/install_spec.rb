require 'spec_helper'
require 'localeapp/cli/install'

describe Localeapp::CLI::Install, '.execute(key = nil)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:command) { Localeapp::CLI::Install.new(:output => output) }

  it "creates the installer based on the config type" do
    command.config_type = :heroku
    command.should_receive(:installer).with("HerokuInstaller").and_return(stub.as_null_object)
    command.execute(key)
  end

  it "executes the installer with the given key" do
    installer = stub(:installer)
    installer.should_receive(:execute).with(key)
    command.stub!(:installer).and_return(installer)
    command.execute(key)
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#execute(key = nil)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.stub!(:print_header)
    installer.stub!(:validate_key)
    installer.stub!(:validate_key).and_return(false)
  end

  it "prints the header" do
    installer.should_receive(:print_header)
    installer.execute
  end

  it "validates the key" do
    installer.should_receive(:validate_key).with(key)
    installer.execute(key)
  end

  context "When key validation fails" do
    it "returns false" do
      installer.execute(key).should == false
    end
  end

  context "When key validation is successful" do
    before do
      installer.stub!(:validate_key).and_return(true)
      installer.stub!(:check_default_locale)
      installer.stub!(:set_config_paths)
      installer.stub!(:write_config_file)
      installer.stub!(:check_data_directory_exists)
    end

    it "checks the default locale" do
      installer.should_receive(:check_default_locale)
      installer.execute(key)
    end

    it "sets the configuration paths" do
      installer.should_receive(:set_config_paths)
      installer.execute(key)
    end

    it "writes the configuration file" do
      installer.should_receive(:write_config_file)
      installer.execute(key)
    end

    it "checks the data directory exists" do
      installer.should_receive(:check_data_directory_exists)
      installer.execute(key)
    end

    it "returns true" do
      installer.execute(key).should == true
    end
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#validate_key(key)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  it "displays error if key is nil" do
    installer.validate_key(nil)
    output.string.should match(/You must supply an API key/)
  end

  it "displays error if the key is there but isn't valid on localeapp.com" do
    installer.stub!(:check_key).and_return([false, {}])
    installer.validate_key(key)
    output.string.should match(/Project not found/)
  end

  it "displays project name if the key is there and valid on localeapp.com" do
    installer.stub!(:check_key).and_return([true, valid_project_data])
    installer.validate_key(key)
    output.string.should match(/Test Project/)
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.stub!(:project_data).and_return(valid_project_data)
  end

  it "displays project base locale" do
    installer.check_default_locale
    output.string.should match(/en \(English\)/)
  end

  it "displays warning if I18n.default_locale doesn't match what's configured on localeapp.com" do
    I18n.stub(:default_locale).and_return(:es)
    installer.check_default_locale
    output.string.should match(%r{WARNING: I18n.default_locale is es, change in config/environment.rb \(Rails 2\) or config/application.rb \(Rails 3\)})
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.set_config_paths
  end

  it "sets the initializer path for a rails app" do
    installer.config_file_path.should == "config/initializers/localeapp.rb"
  end

  it "sets the data directory for a rails app" do
    installer.data_directory.should == "config/locales"
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  it "writes a rails configuration file" do
    installer.stub!(:config_file_path).and_return(path)
    Localeapp.configuration.should_receive(:write_rails_configuration).with(path)
    installer.write_config_file
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#check_data_directory_exists' do
  let(:output) { StringIO.new }
  let(:path) { 'locales' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.stub!(:data_directory).and_return(path)
  end

  it "displays warning if config.translation_data_directory doesn't exist" do
    File.stub(:directory?).with(path).and_return(false)
    installer.check_data_directory_exists
    output.string.should match(/Your translation data will be stored there./)
  end

  it "doesn't display a warning if translation_data_directory exists" do
    File.stub(:directory?).with(path).and_return(true)
    installer.check_data_directory_exists
    output.string.should == ''
  end
end

describe Localeapp::CLI::Install::StandaloneInstaller, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  it "does nothing" do
    installer.check_default_locale
    output.string.should == ''
  end
end

describe Localeapp::CLI::Install::StandaloneInstaller, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  before do
    installer.set_config_paths
  end

  it "sets the initializer path for a standalone app" do
    installer.config_file_path.should == ".localeapp/config.rb"
  end

  it "sets the data directory for a standalone app" do
    installer.data_directory.should == "locales"
  end
end

describe Localeapp::CLI::Install::StandaloneInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  it "writes a standalone configuration file" do
    installer.stub!(:config_file_path).and_return(path)
    Localeapp.configuration.should_receive(:write_standalone_configuration).with(path)
    installer.write_config_file
  end
end

describe Localeapp::CLI::Install::GithubInstaller, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::GithubInstaller.new(output) }

  before do
    installer.set_config_paths
  end

  it "sets the initializer path for a standalone app" do
    installer.config_file_path.should == ".localeapp/config.rb"
  end

  it "sets the data directory for a standalone app" do
    installer.data_directory.should == "locales"
  end
end

describe Localeapp::CLI::Install::GithubInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:installer) { Localeapp::CLI::Install::GithubInstaller.new(output) }

  it "writes a github configuration file" do
    installer.stub!(:config_file_path).and_return(path)
    installer.stub!(:project_data).and_return(valid_project_data)
    Localeapp.configuration.should_receive(:write_github_configuration).with(path, valid_project_data)
    installer.write_config_file
  end
end
