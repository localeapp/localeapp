require "spec_helper"

describe Localeapp::CLI::Copy, "#execute(source_name, dest_name, *rest)" do
  def do_action(source_name = "test.source_name", dest_name = "test.dest_name")
    @command.execute(source_name, dest_name)
  end

  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Copy.new(:output => @output)
  end

  it "makes the api call to the translations endpoint with the destination name as the post body" do
    with_configuration do
      expect(@command).to receive(:api_call).with(
        :copy,
        :url_options => { :source_name => "test.source_name" },
        :payload => { :dest_name => "test.dest_name" },
        :success => :report_success,
        :failure => :report_failure,
        :max_connection_attempts => anything
      )
      do_action
    end
  end
end
