module LocaleappSynchronizationData
  def self.file(dir)
    File.join(dir, 'test_sync.yml')
  end

  def self.setup(polled_at=nil, updated_at=nil)
    polled_at  ||= Time.now.to_i
    updated_at ||= Time.now.to_i

    @dir  = Dir.mktmpdir
    @file = file(@dir)
    File.open(@file, 'w+') do |f|
      f.write({ :polled_at  => polled_at, :updated_at => updated_at }.to_yaml)
    end
    @file
  end

  def self.destroy
    FileUtils.rm_rf @dir
  end
end