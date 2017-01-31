require 'spec_helper'
require 'localeapp/cli/install'

describe Localeapp::CLI::Install, '.execute(key = nil)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:command) { Localeapp::CLI::Install.new(:output => output) }

  it "creates the installer based on the config type" do
    command.config_type = :heroku
    expect(command).to receive(:installer).with("HerokuInstaller").and_return(double.as_null_object)
    command.execute(key)
  end

  it "executes the installer with the given key" do
    installer = double(:installer)
    expect(installer).to receive(:execute).with(key)
    allow(command).to receive(:installer).and_return(installer)
    command.execute(key)
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, "#execute" do
  let(:key)           { "MYAPIKEY" }
  subject(:installer) { described_class.new StringIO.new }

  before do
    allow(installer).to receive(:print_header)
    allow(installer).to receive(:validate_key).and_return(false)
  end

  it "prints the header" do
    expect(installer).to receive(:print_header)
    installer.execute
  end

  it "validates the key" do
    expect(installer).to receive(:key=).with(key)
    expect(installer).to receive(:validate_key)
    installer.execute(key)
  end

  context "When key validation fails" do
    it "returns false" do
      expect(installer.execute(key)).to eq(false)
    end
  end

  context "When key validation is successful" do
    before do
      allow(installer).to receive(:validate_key).and_return(true)
      allow(installer).to receive(:check_default_locale)
      allow(installer).to receive(:set_config_paths)
      allow(installer).to receive(:write_config_file)
      allow(installer).to receive(:check_data_directory_exists)
    end

    it "checks the default locale" do
      expect(installer).to receive(:check_default_locale)
      installer.execute(key)
    end

    it "sets the configuration paths" do
      expect(installer).to receive(:set_config_paths)
      installer.execute(key)
    end

    it "writes the configuration file" do
      expect(installer).to receive(:write_config_file)
      installer.execute(key)
    end

    it "checks the data directory exists" do
      expect(installer).to receive(:check_data_directory_exists)
      installer.execute(key)
    end

    it "returns true" do
      expect(installer.execute(key)).to eq(true)
    end
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#validate_key(key)' do
  let(:output) { StringIO.new }
  let(:key) { 'MYAPIKEY' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.key = key
  end

  it "displays error if key is nil" do
    installer.key = nil
    installer.validate_key
    expect(output.string).to match(/You must supply an API key/)
  end

  it "displays error if the key is there but isn't valid on localeapp.com" do
    allow(installer).to receive(:check_key).and_return([false, {}])
    installer.validate_key
    expect(output.string).to match(/Project not found/)
  end

  it "displays project name if the key is there and valid on localeapp.com" do
    allow(installer).to receive(:check_key).and_return([true, valid_project_data])
    installer.validate_key
    expect(output.string).to match(/Test Project/)
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    allow(installer).to receive(:project_data).and_return(valid_project_data)
  end

  it "displays project base locale" do
    installer.check_default_locale
    expect(output.string).to match(/en \(English\)/)
  end

  it "displays warning if I18n.default_locale doesn't match what's configured on localeapp.com" do
    allow(I18n).to receive(:default_locale).and_return(:es)
    installer.check_default_locale
    expect(output.string)
      .to match(%r{WARNING: I18n\.default_locale is es, change in config/application\.rb \(Rails 3\+\)})
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.set_config_paths
  end

  it "sets the initializer config_file_path for a rails app" do
    expect(installer.config_file_path).to eq("config/initializers/localeapp.rb")
  end

  it "sets the data directory for a rails app" do
    expect(installer.data_directory).to eq("config/locales")
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:config_file_path) { 'config/initializers/localeapp.rb' }
  let(:key) { 'APIKEY' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  it "creates a configuration file containing just the api key" do
    installer.key = key
    installer.config_file_path = config_file_path
    file = double('file')
    expect(file).to receive(:write).with <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = 'APIKEY'
end
CONTENT
    expect(File).to receive(:open).with(config_file_path, 'w+').and_yield(file)
    installer.write_config_file
  end
end

describe Localeapp::CLI::Install::DefaultInstaller, '#check_data_directory_exists' do
  let(:output) { StringIO.new }
  let(:data_directory) { 'locales' }
  let(:installer) { Localeapp::CLI::Install::DefaultInstaller.new(output) }

  before do
    installer.data_directory = data_directory
  end

  it "displays warning if config.translation_data_directory doesn't exist" do
    allow(File).to receive(:directory?).with(data_directory).and_return(false)
    installer.check_data_directory_exists
    expect(output.string).to match(/Your translation data will be stored there./)
  end

  it "doesn't display a warning if translation_data_directory exists" do
    allow(File).to receive(:directory?).with(data_directory).and_return(true)
    installer.check_data_directory_exists
    expect(output.string).to eq('')
  end
end

describe Localeapp::CLI::Install::HerokuInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:config_file_path) { 'config/initializers/localeapp.rb' }
  let(:key) { 'APIKEY' }
  let(:installer) { Localeapp::CLI::Install::HerokuInstaller.new(output) }

  it "creates a configuration file setup for staging / production on heroku" do
    installer.key = key
    installer.config_file_path = config_file_path
    file = double('file')
    expect(file).to receive(:write).with <<-CONTENT
require 'localeapp/rails'

Localeapp.configure do |config|
  config.api_key = ENV['LOCALEAPP_API_KEY']
  config.environment_name = ENV['LOCALEAPP_ENV'] unless ENV['LOCALEAPP_ENV'].nil?
  config.polling_environments = [:development, :staging]
  config.reloading_environments = [:development, :staging]
  config.sending_environments = [:development, :staging]
end

# Pull latest when dyno restarts on staging
if defined?(Rails) && Rails.env.staging?
  Localeapp::CLI::Pull.new.execute
end
CONTENT
    expect(File).to receive(:open).with(config_file_path, 'w+').and_yield(file)
    installer.write_config_file
  end
end
describe Localeapp::CLI::Install::StandaloneInstaller, '#check_default_locale' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  it "does nothing" do
    installer.check_default_locale
    expect(output.string).to eq('')
  end
end

describe Localeapp::CLI::Install::StandaloneInstaller, '#set_config_paths' do
  let(:output) { StringIO.new }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  before do
    installer.set_config_paths
  end

  it "sets the initializer config_file_path for a standalone app" do
    expect(installer.config_file_path).to eq(".localeapp/config.rb")
  end

  it "sets the data directory for a standalone app" do
    expect(installer.data_directory).to eq("locales")
  end
end

describe Localeapp::CLI::Install::StandaloneInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:key) { 'APIKEY' }
  let(:config_file_path) { '.localeapp/config.rb' }
  let(:data_directory) { 'locales' }
  let(:installer) { Localeapp::CLI::Install::StandaloneInstaller.new(output) }

  it "creates a configuration file containing the dot file configuration at the given config_file_path" do
    allow(installer).to receive(:create_config_dir).and_return(File.dirname(config_file_path))
    installer.key = key
    installer.config_file_path = config_file_path
    installer.data_directory = data_directory
    file = double('file')
    expect(file).to receive(:write).with <<-CONTENT
Localeapp.configure do |config|
  config.api_key                    = 'APIKEY'
  config.translation_data_directory = 'locales'
  config.synchronization_data_file  = '.localeapp/log.yml'
  config.daemon_pid_file            = '.localeapp/localeapp.pid'
end
CONTENT
    expect(File).to receive(:open).with(config_file_path, 'w+').and_yield(file)
    installer.write_config_file
  end
end

describe Localeapp::CLI::Install::GithubInstaller, '#write_config_file' do
  let(:output) { StringIO.new }
  let(:key) { 'APIKEY' }
  let(:config_file_path) { '.localeapp/config.rb' }
  let(:data_directory) { 'locales' }
  let(:installer) { Localeapp::CLI::Install::GithubInstaller.new(output) }

  before do
    installer.key = key
    installer.config_file_path = config_file_path
    installer.data_directory = data_directory
    allow(installer).to receive(:create_config_dir).and_return(File.dirname(config_file_path))
    allow(installer).to receive(:write_standalone_config)
    allow(installer).to receive(:create_data_directory)
    allow(installer).to receive(:create_gitignore)
    allow(installer).to receive(:create_readme)
  end

  it "creates a standalone configuration file" do
    expect(installer).to receive(:write_standalone_config)
    installer.write_config_file
  end

  it "creates the data_directory" do
    expect(installer).to receive(:create_data_directory)
    installer.write_config_file
  end

  it "creates the .gitignore file" do
    expect(installer).to receive(:create_gitignore)
    installer.write_config_file
  end

  it "creates the READMI file" do
    expect(installer).to receive(:create_readme)
    installer.write_config_file
  end
end
