require 'spec_helper'

describe LocaleApp::Poller do
  def stub_response(code = 200, hash = {}, headers = {})
    @data = hash.to_json
    @data.stub!(:code).and_return(code)
    headers[:date] ||= Time.now.to_s
    @data.stub!(:headers).and_return(headers)
    @data
  end

  before do
    @tmpdir = Dir.mktmpdir
    @updated_at = Time.now
    @sync_filename = File.join(@tmpdir, 'test_sync.yml')
    File.open(@sync_filename, 'w+') do |file|
      file.write({ :updated_at => @updated_at.to_i }.to_yaml)
    end
    with_configuration(:synchronization_data_file => @sync_filename, :api_key => 'TEST_KEY') do
      @poller = LocaleApp::Poller.new
    end
    @hash = { 'translations' => {}, 'deleted' => [] }
  end

  after do
    FileUtils.rm_rf @tmpdir
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
      FakeWeb.register_uri(:get, "http://api.localeapp.com/projects/TEST_KEY/translations.json?updated_at=#{@updated_at.to_i}", :body => '', :status => ['304', 'Not Modified'])
      @poller.poll!.should == false
    end

    it "returns false if get returns a 50x response" do
      FakeWeb.register_uri(:get, "http://api.localeapp.com/projects/TEST_KEY/translations.json?updated_at=#{@updated_at.to_i}", :body => '', :status => ['500', 'Internal Server Error'])
      @poller.poll!.should == false
    end

    it "returns false if get returns 200 OK" do
      FakeWeb.register_uri(:get, "http://api.localeapp.com/projects/TEST_KEY/translations.json?updated_at=#{@updated_at.to_i}", :body => @hash.to_json, :status => ['200', 'OK'], :date => Time.now.httpdate)
      @poller.poll!.should == true
    end

    it "passes the data through to the Updater" do
      FakeWeb.register_uri(:get, "http://api.localeapp.com/projects/TEST_KEY/translations.json?updated_at=#{@updated_at.to_i}", :body => @hash.to_json, :status => ['200', 'OK'], :date => Time.now.httpdate)
      LocaleApp.updater.should_receive(:update).with(@hash)
      @poller.poll!
    end
  end
end
