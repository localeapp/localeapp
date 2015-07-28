require 'spec_helper'

describe Localeapp::Sender, "#post_translation(locale, key, options, value = nil)" do
  before(:each) do
    with_configuration(:api_key => "TEST_KEY", :sending_environments => ['my_env'], :environment_name => 'my_env') do
      @sender = Localeapp::Sender.new
    end
  end

  let(:response) { double('response', :code => 200) }
  let(:data) { { :translation => {
    :key => "test.key",
    :locale => "en",
    :substitutions => ['bar', 'foo'],
    :description => "test content"
    }}
  }

  def expect_execute
    # have to stub RestClient here as FakeWeb doesn't support looking at the post body yet
    expect(RestClient::Request).to receive(:execute).with(hash_including(
      :url => @sender.translations_url,
      :payload => data.to_json,
      :headers => {
        :x_localeapp_gem_version => Localeapp::VERSION,
        :content_type => :json },
      :method => :post)).and_return(response)
  end

  it "posts the missing translation data to the backend" do
    expect_execute
    @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar', :default => 'default' }, 'test content')
  end

  it "normalizes keys sent with a scope" do
    data[:translation][:key] = 'my.custom.scope.test.key'
    expect_execute
    @sender.post_translation('en', 'test.key', { 'foo' => 'foo', 'bar' => 'bar', :scope => 'my.custom.scope' }, 'test content')
  end
end

describe Localeapp::Sender, "#post_missing_translations" do
  before(:each) do
    with_configuration(:api_key => 'TEST_KEY') do
      @sender = Localeapp::Sender.new
    end
  end

  it "sends the missing translation data to the API" do
    missing_to_send = [
      { :key => "test.key", :locale => "en" },
      { :key => "test.key2", :locale => "en" }
    ]
    expect(Localeapp.missing_translations).to receive(:to_send).and_return(missing_to_send)
    data = { :translations => missing_to_send }
    # have to stub RestClient here as FakeWeb doesn't support looking at the post body yet
    expect(RestClient::Request).to receive(:execute).with(hash_including(
      :url => @sender.missing_translations_url,
      :payload => data.to_json,
      :headers => {
        :x_localeapp_gem_version => Localeapp::VERSION,
        :content_type => :json },
      :method => :post)).and_return(double('response', :code => 200))
    @sender.post_missing_translations
  end

  it "does nothing if there are no missing translations to send" do
    expect(Localeapp.missing_translations).to receive(:to_send).and_return([])
    expect(RestClient).not_to receive(:post)
    @sender.post_missing_translations
  end
end
