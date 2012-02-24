require 'spec_helper'
require 'localeapp/cli/install'

describe Localeapp::CLI::Install, '.execute(key, output = $stdout)' do
  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Install.new
  end

  it "displays error if key is nil" do
    @command.execute(nil, @output)
    @output.string.should match(/You must supply an API key/)
  end

  it "displays error if the key is there but isn't valid on localeapp.com" do
    @command.stub!(:check_key).and_return([false, {}])
    @command.execute('API_KEY', @output)
    @output.string.should match(/Project not found/)
  end

  it "displays project name and base locale if the key is there and valid on localeapp.com" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY', @output)
    @output.string.should match(/Test Project/)
    @output.string.should match(/en \(English\)/)
  end

  it "displays warning if I18n.default_locale doesn't match what's configured on localeapp.com" do
    I18n.stub(:default_locale).and_return(:es)
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY', @output)
    @output.string.should match(%r{WARNING: I18n.default_locale is es, change in config/environment.rb \(Rails 2\) or config/application.rb \(Rails 3\)})
  end

  it "asks the default configuration to write itself" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.should_receive(:write_configuration_file).with('config/initializers/localeapp.rb')
    @command.execute('API_KEY', @output)
  end

  it "asks the configuration to write itself to .localeapp when the --not-rails switch is set" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.config_type = :dot_file
    @command.should_receive(:write_configuration_file).with('.localeapp/config.rb')
    @command.execute('API_KEY', @output)
  end

  it "displays warning if config.translation_data_directory doesn't exist" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY', @output)
    @output.string.should match(/Your translation data will be stored there./)
  end

  it "doesn't display a warning if translation_data_directory exists" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    File.should_receive(:directory?).and_return(true)
    @command.execute('API_KEY', @output)
    @output.string.should_not match(/Your translation data will be stored there./)
  end
end
