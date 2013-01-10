require 'spec_helper'

describe Localeapp, "#load_yaml(content)" do
  it "raises an exception if the content contains potentially insecure yaml" do
    bad_yaml = "---\n- 1\n- 2\n- 3\n- !ruby/object:Object\n    foo: 1\n"
    expect { Localeapp.load_yaml(bad_yaml) }.to raise_error(Localeapp::PotentiallyInsecureYaml)
  end
end
