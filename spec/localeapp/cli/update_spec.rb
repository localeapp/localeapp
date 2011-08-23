require 'spec_helper'
require 'locale_app/cli/update'

describe LocaleApp::CLI::Update, "#execute" do
  before do
    @output = StringIO.new
    @updater = LocaleApp::CLI::Update.new(@output)
  end

  it "creates a Poller and calls poll! on it" do
    with_configuration do
      poller = LocaleApp::Poller.new
      poller.should_receive(:poll!)
      LocaleApp::Poller.should_receive(:new).and_return(poller)
      @updater.execute
    end
  end
end
