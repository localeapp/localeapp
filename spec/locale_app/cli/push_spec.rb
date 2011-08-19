require 'spec_helper'

describe LocaleApp::CLI::Push, "#execute(file)" do
  before do
    @output = StringIO.new
    @pusher = LocaleApp::CLI::Push.new(@output)
  end

  it "creates a new file object and makes the api call to the translations endpoint" do
    with_configuration do
      file = double('file')
      file_path = 'test_path'
      @pusher.stub!(:sanitize_file).and_return(file)
      @pusher.should_receive(:api_call).with(
        :import,
        :payload => { :file => file },
        :success => :report_success,
        :failure => :report_failure,
        :max_connection_attempts => 3
      )
      @pusher.execute(file_path)
    end
  end

  it "doesn't make the api call when the file doesn't exist" do
    @pusher.stub!(:sanitize_file).and_return(nil)
    @pusher.should_not_receive(:api_call)
    @pusher.execute('foo')
  end
end
