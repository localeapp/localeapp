class Olba

  def self.log(str)
    @log ||= Logger.new(STDOUT)
    @log.warn('** [Olba] ' << str)
  end

  def self.handle_missing_translation(locale, key, options)
    log('Posting to hablo.co')
    data = {
      :api_key  => '<API_KEY_HERE>',
      :locale   => locale,
      :key      => key,
      :options  => options,
      :referrer => '<URL_REFERRER>'
    }.to_json
    log(data)
    # send to hablo here
  end

  def self.display_missing_translation(locale, key)
    %Q{<span style="color:red; font-weight:bold; border:2px solid red;">#{locale}, #{key}</span>}
  end
end
