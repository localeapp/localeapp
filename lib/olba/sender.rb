require 'net/http'
require 'uri'

module Olba
  class Sender
    
    def post_translation(locale, key, options)
      data = {
        :api_key  => Olba.configuration.api_key,
        :locale   => locale,
        :key      => key,
        :options  => options }
      response = Net::HTTP.post_form(URI.parse(translation_resource_url), data)
      Olba.log([translation_resource_url, response.code, data.inspect].join(' - '))
    end

    def translation_resource_url
      "http://#{Olba.configuration.host}/translations"
    end

  end
end
