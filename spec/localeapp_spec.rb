require 'spec_helper'

describe Localeapp, "#load_yaml(content)" do
  let(:bad_yaml) { "---\n- 1\n- 2\n- 3\n- !ruby/object:Object\n    foo: 1\n" }

  it "raises an exception if the content contains potentially insecure yaml" do
    with_configuration(:raise_on_insecure_yaml => true) do
      expect { Localeapp.load_yaml(bad_yaml) }.to raise_error(Localeapp::PotentiallyInsecureYaml)
    end
  end

  it "doesn't raise if the raise_on_insecure_yaml setting is false" do
    with_configuration(:raise_on_insecure_yaml => false) do
      expect { Localeapp.load_yaml(bad_yaml) }.to_not raise_error
    end
  end
end

describe Localeapp, "#yaml_data(content, locale_key = nil)" do
  let(:content) { "en:\n   foo: bar" }
  let(:locale_key) { "en" }

  it "raises an exception if the given locale key is missing" do
    with_configuration do
      expect { Localeapp.yaml_data(content, "de") }.to raise_error("Could not find given locale")
    end
  end

  it "finds the given locale key" do
    with_configuration do
      expect(Localeapp.yaml_data(content, locale_key)).to eq({"en" => {"foo" => "bar"}})
    end
  end
end
