require 'spec_helper'

describe LocaleApp::Poller do
  def stub_response(code = 200, hash = {}, headers = {})
    @data = hash.to_json
    @data.stub!(:code).and_return(code)
    headers[:date] ||= Time.now.to_s
    @data.stub!(:headers).and_return(headers)
    @data
  end

  before(:each) do
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

  after(:each) do
    FileUtils.rm_rf @tmpdir
  end

  describe "#write_synchronization_data!(polled_at, updated_at)" do
    it "updates the synchonization data file" do
      update_date = Time.now
      FakeWeb.register_uri(:get, "http://api.localeapp.com/projects/TEST_KEY/translations.json?updated_at=#{@updated_at.to_i}", :body => @hash.to_json, :status => ['200', 'OK'], :date => update_date.httpdate)
      @poller.poll!
      sync_data = YAML.load(File.read(@sync_filename))
      sync_data[:updated_at].should == update_date.to_i
      sync_data[:polled_at].should be_within(5).of(Time.now.to_i)
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
