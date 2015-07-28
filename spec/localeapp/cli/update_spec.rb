require 'spec_helper'
require 'localeapp/cli/update'

describe Localeapp::CLI::Update, "#execute" do
  let(:output)  { StringIO.new }
  let(:updater) { Localeapp::CLI::Update.new(:output => output) }
  let(:poller)  { Localeapp::Poller.new }

  before do
    poller
    allow(Localeapp::Poller).to receive(:new) { poller }
  end

  context "when timestamp is recent" do
    before { allow(poller).to receive(:updated_at) { Time.now.to_i - 60 } }

    it "creates a Poller and calls poll! on it" do
      with_configuration do
        expect(poller).to receive(:poll!)
        updater.execute
      end
    end
  end

  context "when timestamp is too old" do
    before { allow(poller).to receive(:updated_at) { 0 } }

    it "warns the user" do
      with_configuration do
        updater.execute
        expect(output.string).to include("Timestamp is missing or too old.")
      end
    end

    it "does not even call the API" do
      with_configuration do
        expect(poller).not_to receive(:poll!)
        updater.execute
      end
    end
  end
end
