require 'spec_helper'
require 'locale_app/cli/pull'

describe LocaleApp::CLI::Pull, "#execute(output = $stdout)" do
  before do
    @output = StringIO.new
    @puller = LocaleApp::CLI::Pull.new(@output)
  end

  it "makes the api call to the translations endpoint" do
    with_configuration do
      @puller.should_receive(:api_call).with(
        :translations,
        :success => :update_backend,
        :failure => :report_failure,
        :max_connection_attempts => 3
      )
      @puller.execute
    end
  end
end

describe LocaleApp::CLI::Pull, "#update_backend(response)" do
  before do
    @test_data = ['test data'].to_json
    @output = StringIO.new
    @puller = LocaleApp::CLI::Pull.new(@output)
  end

  it "calls the updater" do
    with_configuration do
      LocaleApp.poller.stub!(:write_synchronization_data!)
      LocaleApp.updater.should_receive(:update).with(['test data'])
      @puller.update_backend(@test_data)
    end
  end

  it "writes the synchronization data" do
    with_configuration do
      LocaleApp.updater.stub!(:update)
      LocaleApp.poller.should_receive(:write_synchronization_data!)
      @puller.update_backend(@test_data)
    end
  end
end
