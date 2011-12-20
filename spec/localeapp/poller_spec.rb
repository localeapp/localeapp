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

  describe "#synchronization_data" do
    before do
      @original_configuration_file = Localeapp.configuration.synchronization_data_file
      Localeapp.configuration.synchronization_data_file = "#{File.dirname(__FILE__)}/../fixtures/empty_log.yml"
    end

    it "returns an empty hash if there is a yml file that is empty" do
      @poller.synchronization_data.should == {}
    end

    after do
      Localeapp.configuration.synchronization_data_file = @original_configuration_file
    end
  end

  describe "#write_synchronization_data!(polled_at, updated_at)" do
    it "updates polled_at in the synchronization file" do
      polled_at = lambda { @poller.synchronization_data[:polled_at] }
      expect { @poller.write_synchronization_data!(01234, 56789) }.to change(polled_at, :call).to(01234)
    end

    it "updates updated_at in the synchronization file" do
      updated_at = lambda { @poller.synchronization_data[:updated_at] }
      expect { @poller.write_synchronization_data!(01234, 56789) }.to change(updated_at, :call).to(56789)
    end
  end
    
  describe "#poll!" do
    it "returns false if get returns 304 Not Modified" do
      FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => '', :status => ['304', 'Not Modified'])
      @poller.poll!.should == false
    end

    it "returns false if get returns a 50x response" do
      FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => '', :status => ['500', 'Internal Server Error'])
      @poller.poll!.should == false
    end

    it "returns false if get returns 200 OK" do
      FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => @hash.to_yaml, :status => ['200', 'OK'], :date => Time.now.httpdate)
      @poller.poll!.should == true
    end

    it "passes the data through to the Updater" do
      FakeWeb.register_uri(:get, "https://api.localeapp.com/v1/projects/TEST_KEY/translations.yml?updated_at=#{@updated_at}", :body => @hash.to_yaml, :status => ['200', 'OK'], :date => Time.now.httpdate)
      Localeapp.updater.should_receive(:update).with(@hash)
      @poller.poll!
    end
  end
end
