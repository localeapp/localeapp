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
    headers[:date] ||= Time.now
    @data.stub!(:headers).and_return(headers)
    @data
  end

  it "returns false if get returns 304 Not Modified" do
    RestClient.stub!(:get).and_return(stub_response(304))
    @poller.poll!.should == false
  end

  it "returns false if get returns a 50x response" do
    RestClient.stub!(:get).and_return(stub_response(502))
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
    RestClient.stub!(:get).and_return(stub_response(200, @hash, { :date => update_date }))
    @poller.poll!
    sync_data = YAML.load(File.read(@sync_filename))
    sync_data[:updated_at].should == update_date.to_i
    sync_data[:polled_at].should be_within(5).of(Time.now.to_i)
  end
end

describe LocaleApp::Poller, "#translation_resource_url" do
  before(:each) do
    @tmpdir = Dir.mktmpdir
    @sync_filename = File.join(@tmpdir, 'test_sync.yml')
    @update_date = Time.now
    File.open(@sync_filename, 'w+') { |f| f.write({ :updated_at => @update_date.to_i }.to_yaml) }
    @hash = { 'translations' => {}, 'deleted' => [] }
  end

  after(:each) do
    FileUtils.rm_rf @tmpdir
  end

  def get_url(opts)
    url = nil
    with_configuration({ :synchronization_data_file => @sync_filename }.merge(opts)) do
      url = LocaleApp::Poller.new.translation_resource_url
    end
    url
  end

  it "is constructed from the configuration host, port, api key and updated_at date stored in synchronization file" do
    get_url(
      :host => 'test.host',
      :port => 1234,
      :api_key => 'KEY'
    ).should == "http://test.host:1234/translations.yml?api_key=KEY&updated_at=#{@update_date.to_i}"
  end

  it "includes http auth if if configuration" do
    get_url(
      :host => 'test.host',
      :port => 1234,
      :http_auth_username => 'foo',
      :http_auth_password => 'bar',
      :api_key => 'KEY'
    ).should == "http://foo:bar@test.host:1234/translations.yml?api_key=KEY&updated_at=#{@update_date.to_i}"
  end
end
