require 'spec_helper'

describe Localeapp::CLI::Add, "#execute(current_name, new_name, *rest)" do
  def do_action(current_name = 'test.key', new_name = 'test.new_name')
    @command.execute(current_name, new_name)
  end

  before(:each) do
    @output = StringIO.new
    @command = Localeapp::CLI::Rename.new(:output => @output)
  end

  it "makes the api call to the translations endpoint with the new name as the post body" do
    with_configuration do
      expect(@command).to receive(:api_call).with(
        :rename,
        :url_options => { :current_name => 'test.key' },
        :payload => { :new_name => 'test.new_name' },
        :success => :report_success,
        :failure => :report_failure,
        :max_connection_attempts => anything
      )
      do_action
    end
  end
end
