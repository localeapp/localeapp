require 'spec_helper'

describe Localeapp do

  context '.load_yaml(content)' do

    let(:bad_yaml) { "---\n- 1\n- 2\n- 3\n- !ruby/object:Object\n    foo: 1\n" }

    it 'raises an exception if content contains potentially insecure yaml' do
      with_configuration(:raise_on_insecure_yaml => true) do
        expect {
          described_class.load_yaml(bad_yaml)
        }.to raise_error(Localeapp::PotentiallyInsecureYaml)
      end
    end

    it "doesn't raise if the raise_on_insecure_yaml setting is false" do
      with_configuration(:raise_on_insecure_yaml => false) do
        expect {
          described_class.load_yaml(bad_yaml)
        }.to_not raise_error
      end
    end
  end

  describe '.load_yaml_file(filename, symbolize)' do

    let(:hash_yaml)   { load_yaml 'hash_log.yml' }
    let(:locale_yaml) { load_yaml 'en.yml' }

    context 'with `symbolize = true` for log files' do

      it 'parse yaml with potentially insecure format' do
        filename = file_path 'insecure_log.yml'
        described_class.stub(:rebuild_insecure_log_file)
                       .with(filename)
                       .and_return(load_yaml('hash_log.yml'))

        expect(described_class.load_yaml_file(filename, true)).to eq hash_yaml
      end
    end

    context 'when default' do
      it 'does not alter other yaml files' do
        filename = file_path 'en.yml'
        expect(described_class.load_yaml_file(filename)).to eq locale_yaml
      end
    end
  end

  context '.insecure_yaml?(contents)' do

    it 'returns true when insecure' do
      yaml = File.read file_path('insecure_log.yml')
      expect(described_class.insecure_yaml?(yaml)).to be(true)
    end

    it 'returns false when secure' do
      %w(hash_log.yml string_log.yml empty_log.yml).each do |yaml_file|
        yaml = File.read file_path(yaml_file)
        expect(described_class.insecure_yaml?(yaml)).to be(false)
      end
    end
  end

  context '.symbolize_yaml_keys(contents)' do

    let(:insecure_yaml) { load_yaml 'insecure_log.yml' }
    let(:string_yaml)   { load_yaml 'string_log.yml' }
    let(:hash_yaml)     { load_yaml 'hash_log.yml' }

    it 'symbolize insecure yaml' do
      symbolized = described_class.symbolize_yaml_keys insecure_yaml
      expect(symbolized).to eq hash_yaml
    end

    it 'symbolize string yaml' do
      symbolized = described_class.symbolize_yaml_keys string_yaml
      expect(symbolized).to eq hash_yaml
    end

    it 'do not change format for symbolized keys' do
      symbolized = described_class.symbolize_yaml_keys hash_yaml
      expect(symbolized).to eq hash_yaml
    end
  end

  private

  def load_yaml(filename)
    described_class.yaml_to_hash(File.read(file_path(filename)))
  end

  def file_path(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename).to_s
  end
end
