require 'rest-client'
require 'json'

module LocaleApp
  class Sender
    include ::LocaleApp::Routes

    def post_translation(locale, key, options, value = nil)
      options ||= {}
      translation = { :key => key, :locale => locale, :substitutions => options.keys, :description => value}
      data = { :translation => translation }
      RestClient.post(translations_url, data.to_json, :content_type => :json) do |response, request, result|
        LocaleApp.log([translations_url, response.code, data.inspect].join(' - '))
      end
    end

    def post_missing_translations
      data = { :translations => LocaleApp.missing_translations.to_send }
      RestClient.post(missing_translations_url, data.to_json, :content_type => :json) do |response, request, result|
        LocaleApp.log([missing_translations_url, response.code, data.inspect].join(' - '))
      end
    end
  end
end
