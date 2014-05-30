require 'spec_helper'

describe Localeapp::Poller do
  before do
    @updated_at = Time.now.to_i
    with_configuration(:synchronization_data_file => LocaleappSynchronizationData::setup(nil, @updated_at), :api_key => 'TEST_KEY') do
      @poller = Localeapp::Poller.new
    end
    @hash = { 'translations' => {}, 'deleted' => [], 'locales' => [] }
  end

  after do
    LocaleappSynchronizationData::destroy
  end

  describe "#needs_reloading?" do
    it "returns true when updated_at has been changed in the synchronization file" do
      @poller.write_synchronization_data!(@poller.polled_at, 12345)
      @poller.needs_reloading?.should be_true
    end

    it "returns false when updated_at is the same as in the synchronization file" do
      @poller.needs_reloading?.should be_false
    end
  end

  describe "#write_synchronization_data!(polled_at, updated_at)" do
    let(:polled_at_time) { Time.at(1000000) }
    let(:updated_at_time) { Time.at(1000010) }

    it "updates polled_at in the synchronization file" do
      polled_at = lambda { @poller.sync_data.polled_at }
      expect { @poller.write_synchronization_data!(polled_at_time, updated_at_time) }.to change(polled_at, :call).to(polled_at_time.to_i)
    end

    it "updates updated_at in the synchronization file" do
      updated_at = lambda { @poller.sync_data.updated_at }
      expect { @poller.write_synchronization_data!(polled_at_time, updated_at_time) }.to change(updated_at, :call).to(updated_at_time.to_i)
    end
  end

  describe "#poll!" do
    let(:polled_at_time) { Time.at(1000000) }
    let(:updated_at_time) { Time.at(1000010) }

    describe "when response is 304 Not Modified" do
      before do
        FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => '', :status => ['304', 'Not Modified'], :date => updated_at_time.httpdate)
      end

      it "returns false" do
        @poller.poll!.should == false
      end

      it "updates the polled_at but not the updated_at synchronization data" do
        @poller.stub(:current_time).and_return(polled_at_time)
        @poller.should_receive(:write_synchronization_data!).with(polled_at_time, @updated_at)
        @poller.poll!
      end

      it "updates the synchronization data" do
        @poller.should_receive(:write_synchronization_data!)
        @poller.poll!
      end
    end

    describe "when response is 50x" do
      before do
        FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => '', :status => ['500', 'Internal Server Error'])
      end

      it "returns false" do
        @poller.poll!.should == false
      end

      it "doesn't update the synchronization data" do
        @poller.should_not_receive(:write_synchronization_data!)
        @poller.poll!
      end
    end

    describe "when response is 200" do
      before do
        FakeWeb.register_uri(:get,
          "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}",
          :body => @hash.to_yaml,
          :status => ['200', 'OK'],
          :date => updated_at_time.httpdate
        )
      end

      it "returns true" do
        @poller.poll!.should == true
      end

      it "updates the polled_at and the updated_at synchronization data" do
        @poller.stub(:current_time).and_return(polled_at_time)
        @poller.should_receive(:write_synchronization_data!).with(polled_at_time, updated_at_time)
        @poller.poll!
      end

      it "passes the data through to the Updater" do
        FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => @hash.to_yaml, :status => ['200', 'OK'], :date => Time.now.httpdate)
        Localeapp.updater.should_receive(:update).with(@hash)
        @poller.poll!
      end
    end
  end
end
