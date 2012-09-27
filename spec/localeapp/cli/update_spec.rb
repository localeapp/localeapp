require 'spec_helper'
require 'localeapp/cli/update'

describe Localeapp::CLI::Update, "#execute" do
  before do
    @output = StringIO.new
    @updater = Localeapp::CLI::Update.new(:output => @output)
  end

  it "creates a Poller and calls poll! on it" do
    with_configuration do
      poller = Localeapp::Poller.new
      poller.should_receive(:poll!)
      Localeapp::Poller.should_receive(:new).and_return(poller)
      @updater.execute
    end
  end
end
