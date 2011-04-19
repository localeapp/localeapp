require 'spec_helper'

describe LocaleApp::Poller, "#poll!" do
  before(:each) do
    @tmpdir = Dir.mktmpdir
    @sync_filename = File.join(@tmpdir, 'test_sync.yml')
    with_configuration(:synchronization_data_file => @sync_filename) do
      @poller = LocaleApp::Poller.new
    end
    @hash = { 'translations' => {}, 'deleted' => [] }
  end

  after(:each) do
    FileUtils.rm_rf @tmpdir
  end

  def stub_response(code = 200, hash = {}, headers = {})
    @data = hash.to_json
    @data.stub!(:code).and_return(code)
    headers[:date] ||= Time.now.to_s
    @data.stub!(:headers).and_return(headers)
    @data
  end

  it "returns false if get returns 304 Not Modified" do
    RestClient.stub!(:get).and_raise(RestClient::NotModified)
    @poller.poll!.should == false
  end

  it "returns false if get returns a 50x response" do
    RestClient.stub!(:get).and_raise(RestClient::RequestFailed)
    @poller.poll!.should == false
  end

  it "returns false if get returns 200 OK" do
    RestClient.stub!(:get).and_return(stub_response(200, @hash))
    @poller.poll!.should == true
  end

  it "passes the data through to an Updater" do
    RestClient.stub!(:get).and_return(stub_response(200, @hash))
    LocaleApp::Updater.should_receive(:update).with(@hash)
    @poller.poll!
  end

  it "updates the synchonization data file" do
    update_date = Time.now
    RestClient.stub!(:get).and_return(stub_response(200, @hash, { :date => update_date.to_s }))
    @poller.poll!
    sync_data = YAML.load(File.read(@sync_filename))
    sync_data[:updated_at].should == update_date.to_i
    sync_data[:polled_at].should be_within(5).of(Time.now.to_i)
  end
end