require 'spec_helper'
require 'locale_app/cli/pull'

describe LocaleApp::CLI::Pull, "#execute(output = $stdout)" do
  before do
    @output = StringIO.new
    @puller = LocaleApp::CLI::Pull.new
    @puller.stub!(:sleep_if_retrying) # don't want to sleep in specs
  end

  context "when there is an error response from the server" do
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
      it "retries for the given number of times when #{code} #{reason}" do
        with_configuration do
          @puller.max_connection_attempts = 2
          FakeWeb.register_uri(:get, @puller.translations_url, :body => '', :status => [code.to_s, reason])
          @puller.execute(@output)
          @puller.connection_attempts.should == 2
        end
      end
    end
  end
end
