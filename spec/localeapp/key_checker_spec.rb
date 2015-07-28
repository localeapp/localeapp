require 'spec_helper'

describe Localeapp::KeyChecker, "#check(key)" do
  it "returns false and an empty hash if the response from locale app is a 404" do
    FakeWeb.register_uri(:get, 'https://api.localeapp.com/v1/projects/TEST_KEY.json', :body => "", :status => ['404', 'Not Found'])
    with_configuration do
      @checker = Localeapp::KeyChecker.new
    end
    expect(@checker.check('TEST_KEY')).to eq([false, {}])
  end

  it "returns true and and the parsed json hash if the response from locale app is a 200" do
    FakeWeb.register_uri(:get, 'https://api.localeapp.com/v1/projects/TEST_KEY.json', :body => valid_project_data.to_json, :status => ['200', 'OK'])
    with_configuration do
      @checker = Localeapp::KeyChecker.new
    end
    expect(@checker.check('TEST_KEY')).to eq([true, valid_project_data])
  end
end
