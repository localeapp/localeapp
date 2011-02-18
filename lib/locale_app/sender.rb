require 'rest-client'
require 'json'

module LocaleApp
  class Sender

    def post_translation(locale, key, options, value = nil)
      return if LocaleApp.configuration.disabled?

      options ||= {}
      translation = { :key => key, :locale => locale, :substitutions => options.keys, :description => value}
      data = { :api_key => LocaleApp.configuration.api_key, :translation => translation }
      RestClient.post(translation_resource_url, data.to_json, :content_type => :json, :accept => :json) do |response, request, result|
        LocaleApp.log([translation_resource_url, response.code, data.inspect].join(' - '))
      end
    end

    def translation_resource_url
      "http://#{LocaleApp.configuration.host}:#{LocaleApp.configuration.port}/translations"
    end

  end
end
