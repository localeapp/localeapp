require 'spec_helper'

describe Localeapp::ApiCaller, ".new(endpoint, options = {})" do
  it "stores the endpoint and options" do
    api_caller = Localeapp::ApiCaller.new(:endpoint, :foo => :bar)
    api_caller.endpoint.should == :endpoint
    api_caller.options.should == { :foo => :bar }
  end
end

describe Localeapp::ApiCaller, "#call(object)" do
  before do
    with_configuration do
      @api_caller = Localeapp::ApiCaller.new(:test)
    end
    @url = 'https://example.com/test'
    @api_caller.stub(:test_endpoint).and_return([:get, @url])
    @api_caller.stub(:sleep_if_retrying)
  end

  it "gets the method and url for the endpoint" do
    @api_caller.should_receive(:test_endpoint).with({}).and_return([:get, @url])
    RestClient::Request.stub(:execute).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  it "passes through any url options" do
    @api_caller.should_receive(:test_endpoint).with({:foo => :bar}).and_return([:get, @url])
    @api_caller.options[:url_options] = { :foo => :bar }
    RestClient::Request.stub(:execute).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  it "adds the gem version to the headers" do
    RestClient::Request.should_receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION })).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  if "".respond_to?(:force_encoding)
    def success_check(response)
      response.encoding.should == Encoding.find('UTF-8')
    end

    it "sets the response encoding based on the response charset" do
      response = "string"
      response.stub(:code).and_return(200)
      response.force_encoding('US-ASCII')
      response.stub_chain(:net_http_res, :type_params).and_return('charset' => 'utf-8')
      RestClient::Request.stub(:execute).and_return(response)
      @api_caller.options[:success] = :success_check
      @api_caller.call(self)
    end
  end

  context "Proxy" do
    before do
      RestClient::Request.stub(:execute).and_return(double('response', :code => 200))
    end

    it "sets the proxy if configured" do
      Localeapp.configuration.proxy = "http://localhost:8888"
      RestClient.should_receive(:proxy=).with('http://localhost:8888')
      @api_caller.call(self)
    end

    it "doesn't set the proxy if it's not configured" do
      RestClient.should_not_receive(:proxy=)
      @api_caller.call(self)
    end
  end

  context "SSL Certificate Validation" do
    it "set the HTTPClient verify_ssl to VERIFY_PEER if ssl_verify is set to true" do
      Localeapp.configuration.ssl_verify = true
      RestClient::Request.should_receive(:execute).with(hash_including(:verify_ssl => OpenSSL::SSL::VERIFY_PEER)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "set the HTTPClient verify_ssl to false if ssl_verify is set to false" do
      RestClient::Request.should_receive(:execute).with(hash_including(:verify_ssl => false)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "SSL Certificate Validation" do
    it "set the HTTPClient ca_file to the value given to ssl_ca_file if it's not nil" do
      Localeapp.configuration.ssl_ca_file = '/tmp/test'
      RestClient::Request.should_receive(:execute).with(hash_including(:ca_file => '/tmp/test')).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "doesn't set the HTTPClient ca_file if ssl_ca_file is nil" do
      Localeapp.configuration.ssl_ca_file = nil
      RestClient::Request.should_receive(:execute).with(hash_not_including(:ca_file => nil)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "Timeout" do
    it "sets the timeout to the configured timeout" do
      Localeapp.configuration.timeout = 120
      RestClient::Request.should_receive(:execute).with(hash_including(:timeout => 120)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end
  end

  context "a GET request" do
    it "makes the call to the api" do
      RestClient::Request.should_receive(:execute).with(hash_including(:url => @url, :method => :get)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "adds any :headers to the api call" do
      RestClient::Request.should_receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION, :foo => :bar })).and_return(double('response', :code => 200))
      @api_caller.options[:headers] = { :foo => :bar }
      @api_caller.call(self)
    end
  end


  context " a POST request" do
    before do
      @api_caller.stub(:test_endpoint).and_return([:post, @url])
      @api_caller.options[:payload] = "test data"
    end

    it "makes the call to the api using :payload as the payload" do
      RestClient::Request.should_receive(:execute).with(hash_including(:url => @url, :payload => "test data", :method => :post)).and_return(double('response', :code => 200))
      @api_caller.call(self)
    end

    it "adds any :headers to the api call" do
      RestClient::Request.should_receive(:execute).with(hash_including(:headers => { :x_localeapp_gem_version => Localeapp::VERSION, :foo => :bar })).and_return(double('response', :code => 200))
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
      @object.should_receive(:success).with(kind_of(RestClient::Response))
      @api_caller.call(@object)
    end

    it "does nothing if :success option callback not present" do
      @object.should_not_receive(:success)
      @api_caller.call(@object)
    end

    it "should not try the call again" do
      @api_caller.max_connection_attempts = 2
      @api_caller.call(@object)
      @api_caller.connection_attempts.should == 1
    end

    it "doesn't call the failure handler" do
      @api_caller.options[:failure] = :failure
      @object.should_not_receive(:failure)
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
      @api_caller.connection_attempts.should == 2
    end

    it "backs off each retry attempt" do
      @api_caller.should_receive(:sleep_if_retrying)
      @api_caller.call(@object)
    end

    it "calls the :failure option callback if present" do
      @api_caller.options[:failure] = :fail
      @object.should_receive(:fail).with(kind_of(RestClient::Response))
      @api_caller.call(@object)
    end

    it "does nothing if :failure option callback not present" do
      @object.should_not_receive(:fail)
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
        @object.should_receive(:fail)
        @api_caller.call(@object)
      end
    end

    it "handles ECONNREFUSED" do
      RestClient::Request.stub(:execute).and_raise(Errno::ECONNREFUSED)
      @api_caller.options[:failure] = :fail
      @object.should_receive(:fail)
      @api_caller.call(@object)
    end

    it "handles RestClient::ServerBrokeConnection" do
      RestClient::Request.stub(:execute).and_raise(RestClient::ServerBrokeConnection)
      @api_caller.options[:failure] = :fail
      @object.should_receive(:fail)
      @api_caller.call(@object)
    end

    it "handles SocketError" do
      RestClient::Request.stub(:execute).and_raise(SocketError)
      @api_caller.options[:failure] = :fail
      @object.should_receive(:fail)
      @api_caller.call(@object)
    end
  end
end
