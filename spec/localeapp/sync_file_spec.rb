require 'spec_helper'

describe Localeapp::SyncFile do
  let(:base_dir) { File.join(File.dirname(__FILE__), '../fixtures') }

  context "#data" do
    it "is a default SyncData object" do
      expect(Localeapp::SyncFile.new.data).to eq Localeapp::SyncData.default
    end
  end

  context "#refresh" do
    def sync_file(path)
      Localeapp::SyncFile.new("#{base_dir}/#{path}")
    end

    it "sets the sync data by reading from the path when log file has string keys" do
      file = sync_file('string_log.yml')
      expect{ file.refresh }.to change(file, :data).to(Localeapp::SyncData.new(12345, 67890))
    end

    it "sets the sync data by reading from the path when log file has symbol keys" do
      file = sync_file('symbol_log.yml')
      expect{ file.refresh }.to change(file, :data).to(Localeapp::SyncData.new(54321, 98760))
    end

    it "sets the sync data to default values when file is missing" do
      file = sync_file('this_file_does_not_exist.yml')
      expect{ file.refresh }.to_not change(file, :data)
    end

    it "sets the sync data to default values when file is empty" do
      file = sync_file('empty_log.yml')
      expect{ file.refresh }.to_not change(file, :data)
    end
  end

  context "#write" do
    let(:file) { Localeapp::SyncFile.new("#{base_dir}/example_write.yml") }

    after do
      File.delete("#{base_dir}/example_write.yml")
    end

    it "sets polled_at" do
      polled_at = Proc.new { file.data.polled_at }
      expect{ file.write('aaa', 'bbb') }.to change(polled_at, :call).to('aaa')
    end

    it "sets updated_at" do
      updated_at = Proc.new { file.data.updated_at }
      expect{ file.write('ccc', 'ddd') }.to change(updated_at, :call).to('ddd')
    end

    it "writes to the configuration file" do
      file.write(123, 456)
      # using a regexp here since 1.9.3 output has an extra space after the first "---"
      expect( File.read("#{base_dir}/example_write.yml") ).to match /--- ?\npolled_at: 123\nupdated_at: 456\n/
    end
  end
end
