require 'spec_helper'

describe Localeapp::CLI::Daemon, "#execute(options)" do
  let(:output) { StringIO.new }
  let(:command) { Localeapp::CLI::Daemon.new(:output => output) }
  let(:interval) { 5 }

  before do
    allow(command).to receive(:update_loop)
  end

  it "exits when interval isn't greater than 0" do
    expect(command).to receive(:exit_now!)
    command.execute(:interval => -1)
  end

  it "runs the loop directly when not running in background" do
    expect(command).to receive(:update_loop).with(interval)
    command.execute(:interval => interval)
  end

  it "runs the loop in the background when background options set" do
    expect(command).to receive(:run_in_background).with(interval)
    command.execute(:interval => interval, :background => true)
  end
end

describe Localeapp::CLI::Daemon, "#do_update" do
  let(:output) { StringIO.new }
  let(:command) { Localeapp::CLI::Daemon.new(:output => output) }

  it "creates and executes and Updater" do
    stub = double(:updater)
    expect(stub).to receive(:execute)
    expect(Localeapp::CLI::Update).to receive(:new).and_return(stub)
    command.do_update
  end
end
