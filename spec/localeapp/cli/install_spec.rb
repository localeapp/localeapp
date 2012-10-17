require 'spec_helper'
require 'localeapp/cli/install'

describe Localeapp::CLI::Install, '.execute(key, output = $stdout)' do
  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Install.new(:output => @output)
  end

  context "heroku install" do
    let(:heroku_configurator) { stub.as_null_object }

    before do
      @command.config_type = :heroku
    end

    it "creates a HerokuConfigurator" do
      Localeapp::CLI::Install::HerokuConfigurator.should_receive(:new).with(@output, nil).and_return(heroku_configurator)
      @command.execute
    end

    xit "gets the api key from the heroku config" do
      @command.config_type = :heroku
      @command.should_receive(:get_heroku_api_key).and_return('MYAPIKEY')
      @command.stub!(:check_key).and_return([true, valid_project_data])
      @command.stub!(:write_configuration_file)
      @command.execute
    end
  end

  xit "displays error if key is nil" do
    @command.execute(nil)
    @output.string.should match(/You must supply an API key/)
  end

  xit "displays error if the key is there but isn't valid on localeapp.com" do
    @command.stub!(:check_key).and_return([false, {}])
    @command.execute('API_KEY')
    @output.string.should match(/Project not found/)
  end

  xit "displays project name and base locale if the key is there and valid on localeapp.com" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY')
    @output.string.should match(/Test Project/)
    @output.string.should match(/en \(English\)/)
  end

  xit "displays warning if I18n.default_locale doesn't match what's configured on localeapp.com" do
    I18n.stub(:default_locale).and_return(:es)
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY')
    @output.string.should match(%r{WARNING: I18n.default_locale is es, change in config/environment.rb \(Rails 2\) or config/application.rb \(Rails 3\)})
  end

  xit "asks the default configuration to write itself" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.should_receive(:write_configuration_file).with('config/initializers/localeapp.rb')
    @command.execute('API_KEY')
  end

  xit "asks the configuration to write itself to .localeapp when the --standalone switch is set" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.config_type = :standalone
    @command.should_receive(:write_configuration_file).with('.localeapp/config.rb')
    @command.execute('API_KEY')
  end

  xit "displays warning if config.translation_data_directory doesn't exist" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    @command.execute('API_KEY')
    @output.string.should match(/Your translation data will be stored there./)
  end

  xit "doesn't display a warning if translation_data_directory exists" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.stub!(:write_configuration_file)
    File.should_receive(:directory?).and_return(true)
    @command.execute('API_KEY')
    @output.string.should_not match(/Your translation data will be stored there./)
  end

  xit "asks the github configuration to write itself" do
    @command.stub!(:check_key).and_return([true, valid_project_data])
    @command.config_type = :github
    @command.should_receive(:write_github_configuration_file).with('.localeapp/config.rb', valid_project_data)
    @command.execute('API_KEY')
  end
end
