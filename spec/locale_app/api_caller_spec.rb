require 'spec_helper'

describe LocaleApp::ApiCaller, ".new(endpoint, options = {})" do
  it "stores the endpoint and options" do
    api_caller = LocaleApp::ApiCaller.new(:endpoint, :foo => :bar)
    api_caller.endpoint.should == :endpoint
    api_caller.options.should == { :foo => :bar }
  end
end

describe LocaleApp::ApiCaller, "#call(object)" do
  before do
    @api_caller = LocaleApp::ApiCaller.new(:test)
    @url = 'http://example.com/test'
    @api_caller.stub!(:test_endpoint).and_return([:get, @url])
    @api_caller.stub!(:sleep_if_retrying)
  end

  it "gets the method and url for the endpoint" do
    @api_caller.should_receive(:test_endpoint).and_return([:get, @url])
    RestClient.stub!(:get).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  it "makes the call to the api" do
    RestClient.should_receive(:get).with(@url).and_return(double('response', :code => 200))
    @api_caller.call(self)
  end

  context " a POST request" do
    it "uses the content of the :payload option as the payload" do
      @api_caller.stub!(:test_endpoint).and_return([:post, @url])
      @api_caller.options[:payload] = "test data"
      RestClient.should_receive(:post).with(@url, "test data").and_return(double('response', :code => 200))
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
  end
end
