require 'spec_helper'

class ApiCallTest
  include LocaleApp::ApiCall
end

describe LocaleApp::ApiCall, "#api_call(endpoint, options = {})" do
  it "creates an ApiCaller object and tells it to make the call" do
    api_call_test = ApiCallTest.new
    api_call = double('api_call')
    api_call.should_receive(:call).with(api_call_test)
    LocaleApp::ApiCaller.should_receive(:new).with(:endpoint, { :foo => :bar }).and_return(api_call)
    api_call_test.api_call(:endpoint, { :foo => :bar })
  end
end
