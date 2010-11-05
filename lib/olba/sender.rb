require 'rest-client'
require 'json'

module Olba
  class Sender

    def post_translation(locale, key, options={}, value=nil)
      translation = { :key => key, :locale => locale, :substitutions => options.keys, :description => value}
      data = { :api_key => Olba.configuration.api_key, :translation => translation }
      RestClient.post(translation_resource_url, data.to_json, :content_type => :json, :accept => :json) do |response, request, result|
        Olba.log([translation_resource_url, response.code, data.inspect].join(' - '))
      end
    end

    def translation_resource_url
      "http://#{Olba.configuration.host}:#{Olba.configuration.port}/translations"
    end

  end
end
