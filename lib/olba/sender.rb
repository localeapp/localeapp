module Olba
  class Sender
    
    def post_translation(locale, key, options)
      Olba.log('Posting to hablo.co')
      data = {
        :api_key  => Olba.configuration.api_key,
        :locale   => locale,
        :key      => key,
        :options  => options
      }
      Olba.log(data.inspect)
    end

  end
end
