require 'yaml'

module Localeapp
  SyncFile = Struct.new(:path) do
    def refresh
      @data = if File.exist?(path)
        SyncData.from_hash( Localeapp.load_yaml_file(path) )
      else
        SyncData.default
      end
    end

    def write(polled_at, updated_at)
      data.polled_at  = polled_at
      data.updated_at = updated_at
      File.open(path, 'w+') { |f| f.write(data.to_yaml) }
    end

    def data
      @data ||= SyncData.default
    end
  end

  SyncData = Struct.new(:polled_at, :updated_at) do
    def self.default
      new(0, 0)
    end

    def self.from_hash(hash)
      return default unless hash.is_a?(Hash)
      new(
        hash['polled_at']  || hash[:polled_at],
        hash['updated_at'] || hash[:updated_at]
      )
    end

    def to_hash
      {'polled_at' => polled_at.to_i, 'updated_at' => updated_at.to_i}
    end

    def to_yaml
      to_hash.to_yaml
    end
  end
end
