require 'spec_helper'
require 'locale_app/cli/install'

describe LocaleApp::CLI::Install, '.execute(key, output = $stdout)' do
  before(:each) do
    @output = StringIO.new
    @command = LocaleApp::CLI::Install.new
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
end
