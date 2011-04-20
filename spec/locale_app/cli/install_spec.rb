require 'spec_helper'
require 'locale_app/cli/install'

describe LocaleApp::CLI::Install, '.execute(key, output = $stdout)' do
  before(:each) do
    @output = StringIO.new
  end

  it "displays error if key is nil" do
    command = LocaleApp::CLI::Install.new
    command.execute(nil, @output)
    @output.string.should match(/You must supply an API key/)
  end

  it "displays error if the key is there but isn't valid on localeapp.com" do
    command = LocaleApp::CLI::Install.new
    command.stub!(:check_key).and_return([false, {}])
    command.execute('API_KEY', @output)
    @output.string.should match(/Project not found/)
  end

  it "displays project name and base locale if the key is there and valid on localeapp.com" do
    command = LocaleApp::CLI::Install.new
    command.stub!(:check_key).and_return([true, valid_project_data])
    command.execute('API_KEY', @output)
    @output.string.should match(/Test Project/)
    @output.string.should match(/en \(English\)/)
  end
end
