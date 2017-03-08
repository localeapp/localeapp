require 'rest-client'
require 'json'

module Localeapp
  class Sender
    include ::Localeapp::ApiCall
    include ::Localeapp::Routes

    def post_translation(locale, key, options, value = nil)
      options ||= {}
      options.delete(:default)
      scope = options.delete(:scope)
      normalized_key = I18n.normalize_keys(nil, key, scope).join('.')

      translation = { :key => normalized_key, :locale => locale, :substitutions => options.keys.sort, :description => value}
      @data = { :translation => translation }
      api_call :create_translation,
        :payload => @data.to_json,
        :headers => { :content_type => :json },
        :success => :handle_single_translation_success,
        :failure => :handle_single_translation_failure,
        :max_connection_attempts => 1
    end

    def handle_single_translation_success(response)
       Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def handle_single_translation_failure(response)
       Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def post_missing_translations
      to_send = Localeapp.missing_translations.to_send
      return if to_send.empty?
      @data = { :translations => to_send }
      api_call :missing_translations,
        :payload => @data.to_json,
        :headers => { :content_type => :json },
        :success => :handle_missing_translation_success,
        :failure => :handle_missing_translation_failure,
        :max_connection_attempts => 1
    end

    def handle_missing_translation_success(response)
       Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def handle_missing_translation_failure(response)
       Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
       fail APIResponseError, "API returned #{response.code} status code"
    end
  end
end
