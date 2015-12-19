require 'spec_helper'

describe Localeapp::ApiCaller, ".new(endpoint, options = {})" do
  it "stores the endpoint and options" do
    api_caller = Localeapp::ApiCaller.new(:endpoint, :foo => :bar)
    expect(api_caller.endpoint).to eq(:endpoint)
    expect(api_caller.options).to eq({ :foo => :bar })
  end
end

describe Localeapp::ApiCaller, "#call(object)" do
  before do
    with_configuration do
      @api_caller = Localeapp::ApiCaller.new(:test)
    end
    @url = 'https://example.com/test'
    allow(@api_caller).to receive(:test_endpoint).and_return([:get, @url])
    allow(@api_caller).to receive(:sleep_if_retrying)
  end

  it "gets the method and url for the endpoint" do
    expect(@api_caller).to receive(:test_endpoint).with({}).and_return([:get, @url])
    allow(RestClient::Request).to receive(:execute).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  it "passes through any url options" do
    expect(@api_caller).to receive(:test_endpoint).with({:foo => :bar}).and_return([:get, @url])
    @api_caller.options[:url_options] = { :foo => :bar }
    allow(RestClient::Request).to receive(:execute).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  it "adds the gem version to the headers" do
    expect(RestClient::Request).to receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION })).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  if "".respond_to?(:force_encoding)
    def success_check(response)
      expect(response.encoding).to eq(Encoding.find('UTF-8'))
    end

    it "sets the response encoding based on the response charset" do
      response = "string"
      allow(response).to receive(:code).and_return(200)
      response.force_encoding('US-ASCII')
      allow(response).to receive_message_chain(:net_http_res, :type_params) do
        { "charset" => "utf-8" }
      end
      allow(RestClient::Request).to receive(:execute).and_return(response)
      @api_caller.options[:success] = :success_check
      @api_caller.call(self)
    end
  end

  context "Proxy" do
    before do
      allow(RestClient::Request).to receive(:execute).and_return(double('response', :code => 200))
    end

    it "sets the proxy if configured" do
      Localeapp.configuration.proxy = "http://localhost:8888"
      expect(RestClient).to receive(:proxy=).with('http://localhost:8888')
      @api_caller.call(self)
    end

    it "doesn't set the proxy if it's not configured" do
      expect(RestClient).not_to receive(:proxy=)
      @api_caller.call(self)
    end
  end

  context "SSL Certificate Validation" do
    it "set the HTTPClient verify_ssl to VERIFY_PEER if ssl_verify is set to true" do
      Localeapp.configuration.ssl_verify = true
      expect(RestClient::Request).to receive(:execute).with(hash_including(:verify_ssl => OpenSSL::SSL::VERIFY_PEER)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "set the HTTPClient verify_ssl to false if ssl_verify is set to false" do
      expect(RestClient::Request).to receive(:execute).with(hash_including(:verify_ssl => false)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "SSL Certificate Validation" do
    it "set the HTTPClient ca_file to the value given to ssl_ca_file if it's not nil" do
      Localeapp.configuration.ssl_ca_file = '/tmp/test'
      expect(RestClient::Request).to receive(:execute).with(hash_including(:ca_file => '/tmp/test')).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "doesn't set the HTTPClient ca_file if ssl_ca_file is nil" do
      Localeapp.configuration.ssl_ca_file = nil
      expect(RestClient::Request).to receive(:execute).with(hash_not_including(:ca_file => nil)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "SSL version" do
    it "sets the HTTPClient ssl_version to the value given to ssl_version" do
      Localeapp.configuration.ssl_version = 'SSLv3'
      expect(RestClient::Request).to receive(:execute).with(hash_including(:ssl_version => 'SSLv3')).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "doesn't set the HTTPClient ssl_version if it's nil" do
      Localeapp.configuration.ssl_version = nil
      expect(RestClient::Request).to receive(:execute).with(hash_including(:ssl_version => nil)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "Timeout" do
    it "sets the timeout to the configured timeout" do
      Localeapp.configuration.timeout = 120
      expect(RestClient::Request).to receive(:execute).with(hash_including(:timeout => 120)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "a GET request" do
    it "makes the call to the api" do
      expect(RestClient::Request).to receive(:execute).with(hash_including(:url => @url, :method => :get)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "adds any :headers to the api call" do
      expect(RestClient::Request).to receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION, :foo => :bar })).and_return(double('response', :code => 200))
      @api_caller.options[:headers] = { :foo => :bar }
      @api_caller.call(self)
    end
  end


  context " a POST request" do
    before do
      allow(@api_caller).to receive(:test_endpoint).and_return([:post, @url])
      @api_caller.options[:payload] = "test data"
    end

    it "makes the call to the api using :payload as the payload" do
      expect(RestClient::Request).to receive(:execute).with(hash_including(:url => @url, :payload => "test data", :method => :post)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "adds any :headers to the api call" do
      expect(RestClient::Request).to receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION, :foo => :bar })).and_return(double('response', :code => 200))
      @api_caller.options[:headers] = { :foo => :bar }
      @api_caller.call(self)
    end
  end

  context " call succeeded" do
    before do
      FakeWeb.register_uri(:get, @url, :body => '', :status => [200, 'OK'])
      @object = double('calling object')
    end

    it "calls the :success option callback if present" do
      @api_caller.options[:success] = :success
      expect(@object).to receive(:success).with(kind_of(RestClient::Response))
      @api_caller.call(@object)
    end

    it "does nothing if :success option callback not present" do
      expect(@object).not_to receive(:success)
      @api_caller.call(@object)
    end

    it "should not try the call again" do
      @api_caller.max_connection_attempts = 2
      @api_caller.call(@object)
      expect(@api_caller.connection_attempts).to eq(1)
    end

    it "doesn't call the failure handler" do
      @api_caller.options[:failure] = :failure
      expect(@object).not_to receive(:failure)
      @api_caller.call(@object)
    end
  end

  context " call failed" do
    before do
      FakeWeb.register_uri(:get, @url, :body => '', :status => [500, 'Internal Server Error'])
      @object = double('calling object')
    end

    it "retries call, up to value of :max_connection_attempts option" do
      @api_caller.max_connection_attempts = 2
      @api_caller.call(@object)
      expect(@api_caller.connection_attempts).to eq(2)
    end

    it "backs off each retry attempt" do
      expect(@api_caller).to receive(:sleep_if_retrying)
      @api_caller.call(@object)
    end

    it "calls the :failure option callback if present" do
      @api_caller.options[:failure] = :fail
      expect(@object).to receive(:fail).with(kind_of(RestClient::Response))
      @api_caller.call(@object)
    end

    it "does nothing if :failure option callback not present" do
      expect(@object).not_to receive(:fail)
      @api_caller.call(@object)
    end

    {
      304 => 'Not Modified',
      404 => 'Resource Not Found',
      422 => 'Unprocessable Entity',
      500 => 'Internal Server Error',
      # Work out when this could happen
      # 501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Timeout',
      # Work out when this could happen
      # 505 => 'HTTP Version Not Supported',
      # Work out when this could happen
      # 506 => 'Variant Also Negotiates',
      # Work out when this could happen
      # 507 => 'Insufficient Storage', #WebDAV
      # Work out when this could happen
      # 509 => 'Bandwidth Limit Exceeded', #Apache
      # Work out when this could happen
      # 510 => 'Not Extended'
    }.each do |code, reason|
      it "fails when response is #{code} #{reason}" do
        FakeWeb.register_uri(:get, @url, :body => '', :status => [code.to_s, reason])
        @api_caller.options[:failure] = :fail
        expect(@object).to receive(:fail)
        @api_caller.call(@object)
      end
    end

    it "handles ECONNREFUSED" do
      allow(RestClient::Request).to receive(:execute).and_raise(Errno::ECONNREFUSED)
      @api_caller.options[:failure] = :fail
      expect(@object).to receive(:fail)
      @api_caller.call(@object)
    end

    it "handles RestClient::ServerBrokeConnection" do
      allow(RestClient::Request).to receive(:execute).and_raise(RestClient::ServerBrokeConnection)
      @api_caller.options[:failure] = :fail
      expect(@object).to receive(:fail)
      @api_caller.call(@object)
    end

    it "handles SocketError" do
      allow(RestClient::Request).to receive(:execute).and_raise(SocketError)
      @api_caller.options[:failure] = :fail
      expect(@object).to receive(:fail)
      @api_caller.call(@object)
    end
  end
end
