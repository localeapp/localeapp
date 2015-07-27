require 'spec_helper'

describe Localeapp::CLI::Push, "#execute(path)" do
  let(:output) { StringIO.new }
  let(:pusher) { Localeapp::CLI::Push.new(:output => output) }

  context "path is a directory" do
    let(:path)  { "spec/fixtures/locales" }

    it "calls push_file on each YAML file in the directory" do
      with_configuration do
        expect(pusher).to receive(:push_file).with File.join(path, "en.yml")
        expect(pusher).to receive(:push_file).with File.join(path, "es.yml")
        pusher.execute path
      end
    end

    context "when JSON format is configured" do
      around { |example| with_configuration(format: :json) { example.run } }

      it "calls push_file on each JSON file in the directory" do
        expect(pusher).to receive(:push_file).with File.join(path, "en.json")
        expect(pusher).to receive(:push_file).with File.join(path, "es.json")
        pusher.execute path
      end
    end
  end

  context "path is a file" do
    it "calls push_file on the file" do
      with_configuration do
        file = double('file')
        file_path = 'test_path'
        expect(pusher).to receive(:push_file).with(file_path)
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
      allow(pusher).to receive(:sanitize_file).and_return(file)
      expect(pusher).to receive(:api_call).with(
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
    allow(pusher).to receive(:sanitize_file).and_return(nil)
    expect(pusher).not_to receive(:api_call)
    pusher.push_file('foo')
  end
end
