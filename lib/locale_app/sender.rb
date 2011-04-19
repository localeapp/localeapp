require 'rest-client'
require 'json'

module LocaleApp
  class Sender
    include ::LocaleApp::Routes

    def post_translation(locale, key, options, value = nil)
      return if LocaleApp.configuration.disabled?

      options ||= {}
      translation = { :key => key, :locale => locale, :substitutions => options.keys, :description => value}
      data = { :translation => translation }
      RestClient.post(translations_url, data.to_json, :content_type => :json, :accept => :json) do |response, request, result|
        LocaleApp.log([translations_url, response.code, data.inspect].join(' - '))
      end
    end
  end
end
