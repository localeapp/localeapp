require 'spec_helper'
require 'localeapp/cli/install'

describe Localeapp::CLI::Install, '.execute(key = nil)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:command) { Localeapp::CLI::Install.new(:output => output) }

  it "creates the configurator based on the config type" do
    command.config_type = :heroku
    command.should_receive(:configurator).with("HerokuConfigurator").and_return(stub.as_null_object)
    command.execute(key)
  end

  it "executes the configurator with the given key" do
    configurator = stub(:configurator)
    configurator.should_receive(:execute).with(key)
    command.stub!(:configurator).and_return(configurator)
    command.execute(key)
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#execute(key = nil)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  before do
    configurator.stub!(:print_header)
    configurator.stub!(:validate_key)
    configurator.stub!(:valid_key).and_return(false)
  end

  it "prints the header" do
    configurator.should_receive(:print_header)
    configurator.execute
  end

  it "validates the key" do
    configurator.should_receive(:validate_key).with(key)
    configurator.execute(key)
  end

  context "When key validation fails" do
    it "returns false" do
      configurator.execute(key).should == false
    end
  end

  context "When key validation is successful" do
    before do
      configurator.stub!(:valid_key).and_return(true)
      configurator.stub!(:check_default_locale)
      configurator.stub!(:set_config_paths)
      configurator.stub!(:write_config_file)
      configurator.stub!(:check_data_directory_exists)
    end

    it "checks the default locale" do
      configurator.should_receive(:check_default_locale)
      configurator.execute(key)
    end

    it "sets the configuration paths" do
      configurator.should_receive(:set_config_paths)
      configurator.execute(key)
    end

    it "writes the configuration file" do
      configurator.should_receive(:write_config_file)
      configurator.execute(key)
    end

    it "checks the data directory exists" do
      configurator.should_receive(:check_data_directory_exists)
      configurator.execute(key)
    end

    it "returns true" do
      configurator.execute(key).should == true
    end
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#validate_key(key)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  it "displays error if key is nil" do
    configurator.validate_key(nil)
    output.string.should match(/You must supply an API key/)
  end

  it "displays error if the key is there but isn't valid on localeapp.com" do
    configurator.stub!(:check_key).and_return([false, {}])
    configurator.validate_key(key)
    output.string.should match(/Project not found/)
  end

  it "displays project name if the key is there and valid on localeapp.com" do
    configurator.stub!(:check_key).and_return([true, valid_project_data])
    configurator.validate_key(key)
    output.string.should match(/Test Project/)
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  before do
    configurator.stub!(:project_data).and_return(valid_project_data)
  end

  it "displays project base locale" do
    configurator.check_default_locale
    output.string.should match(/en \(English\)/)
  end

  it "displays warning if I18n.default_locale doesn't match what's configured on localeapp.com" do
    I18n.stub(:default_locale).and_return(:es)
    configurator.check_default_locale
    output.string.should match(%r{WARNING: I18n.default_locale is es, change in config/environment.rb \(Rails 2\) or config/application.rb \(Rails 3\)})
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  before do
    configurator.set_config_paths
  end

  it "sets the initializer path for a rails app" do
    configurator.config_file_path.should == "config/initializers/localeapp.rb"
  end

  it "sets the data directory for a rails app" do
    configurator.data_directory.should == "config/locales"
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  it "writes a rails configuration file" do
    configurator.stub!(:config_file_path).and_return(path)
    Localeapp.configuration.should_receive(:write_rails_configuration).with(path)
    configurator.write_config_file
  end
end

describe Localeapp::CLI::Install::DefaultConfigurator, '#check_data_directory_exists' do
  let(:output) { StringIO.new }
  let(:path) { 'locales' }
  let(:configurator) { Localeapp::CLI::Install::DefaultConfigurator.new(output) }

  before do
    configurator.stub!(:data_directory).and_return(path)
  end

  it "displays warning if config.translation_data_directory doesn't exist" do
    File.stub(:directory?).with(path).and_return(false)
    configurator.check_data_directory_exists
    output.string.should match(/Your translation data will be stored there./)
  end

  it "doesn't display a warning if translation_data_directory exists" do
    File.stub(:directory?).with(path).and_return(true)
    configurator.check_data_directory_exists
    output.string.should == ''
  end
end

describe Localeapp::CLI::Install::StandaloneConfigurator, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:configurator) { Localeapp::CLI::Install::StandaloneConfigurator.new(output) }

  it "does nothing" do
    configurator.check_default_locale
    output.string.should == ''
  end
end

describe Localeapp::CLI::Install::StandaloneConfigurator, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:configurator) { Localeapp::CLI::Install::StandaloneConfigurator.new(output) }

  before do
    configurator.set_config_paths
  end

  it "sets the initializer path for a standalone app" do
    configurator.config_file_path.should == ".localeapp/config.rb"
  end

  it "sets the data directory for a standalone app" do
    configurator.data_directory.should == "locales"
  end
end

describe Localeapp::CLI::Install::StandaloneConfigurator, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:configurator) { Localeapp::CLI::Install::StandaloneConfigurator.new(output) }

  it "writes a standalone configuration file" do
    configurator.stub!(:config_file_path).and_return(path)
    Localeapp.configuration.should_receive(:write_standalone_configuration).with(path)
    configurator.write_config_file
  end
end

describe Localeapp::CLI::Install::GithubConfigurator, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:configurator) { Localeapp::CLI::Install::GithubConfigurator.new(output) }

  before do
    configurator.set_config_paths
  end

  it "sets the initializer path for a standalone app" do
    configurator.config_file_path.should == ".localeapp/config.rb"
  end

  it "sets the data directory for a standalone app" do
    configurator.data_directory.should == "locales"
  end
end

describe Localeapp::CLI::Install::GithubConfigurator, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:path) { 'path' }
  let(:configurator) { Localeapp::CLI::Install::GithubConfigurator.new(output) }

  it "writes a github configuration file" do
    configurator.stub!(:config_file_path).and_return(path)
    configurator.stub!(:project_data).and_return(valid_project_data)
    Localeapp.configuration.should_receive(:write_github_configuration).with(path, valid_project_data)
    configurator.write_config_file
  end
end
