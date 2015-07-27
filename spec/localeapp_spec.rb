require 'spec_helper'

describe Localeapp, "#load(content)" do
  let(:bad_yaml) { "---\n- 1\n- 2\n- 3\n- !ruby/object:Object\n    foo: 1\n" }

  it "raises an exception if the content contains potentially insecure yaml" do
    with_configuration(:raise_on_insecure_yaml => true) do
      expect { Localeapp.load_locale(bad_yaml) }.to raise_error(Localeapp::PotentiallyInsecureYaml)
    end
  end

  it "doesn't raise if the raise_on_insecure_yaml setting is false" do
    with_configuration(:raise_on_insecure_yaml => false) do
      expect { Localeapp.load_locale(bad_yaml) }.to_not raise_error
    end
  end
end
