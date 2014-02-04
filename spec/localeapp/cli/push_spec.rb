require 'spec_helper'

describe Localeapp::CLI::Push, "#execute(path)" do
  let(:output) { StringIO.new }
  let(:pusher) { Localeapp::CLI::Push.new(:output => output) }

  context "path is a directory" do
    it "calls push_file on each yaml file in the directory" do
      with_configuration do
        directory = double('directory')
        path = 'test_path'
        yaml_files = %w(en.yml es.yml)
        pusher.stub(:path_is_directory?).and_return(true)
        pusher.should_receive(:yaml_files_in_directory).with(path).and_return(yaml_files)
        pusher.should_receive(:push_file).with('en.yml')
        pusher.should_receive(:push_file).with('es.yml')
        pusher.execute(path)
      end
    end
  end

  context "path is a file" do
    it "calls push_file on the file" do
      with_configuration do
        file = double('file')
        file_path = 'test_path'
        pusher.should_receive(:push_file).with(file_path)
        pusher.execute(file_path)
      end
    end
  end
end

describe Localeapp::CLI::Push, "#push_file(file_path)" do
  let(:output) { StringIO.new }
  let(:pusher) { Localeapp::CLI::Push.new(:output => output) }

  it "creates a new file object and makes the api call to the translations endpoint" do
    with_configuration do
      file = double('file')
      file_path = 'test_path'
      pusher.stub(:sanitize_file).and_return(file)
      pusher.should_receive(:api_call).with(
        :import,
        :payload => { :file => file },
        :success => :report_success,
        :failure => :report_failure,
        :max_connection_attempts => 3
      )
      pusher.push_file(file_path)
    end
  end

  it "doesn't make the api call when the file doesn't exist" do
    pusher.stub(:sanitize_file).and_return(nil)
    pusher.should_not_receive(:api_call)
    pusher.push_file('foo')
  end
end
