require 'rest-client'
require 'json'

module Localeapp
  class Sender
    include ::Localeapp::ApiCall
    include ::Localeapp::Routes

    def post_translation(locale, key, options, value = nil)
      options ||= {}
      options.delete(:default)
      options.delete(:scope)
      translation = { :key => key, :locale => locale, :substitutions => options.keys.sort, :description => value}
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
      Localeapp.debug "post_missing_translations: getting translations to send"
      to_send = Localeapp.missing_translations.to_send
      Localeapp.debug "post_missing_translations: checking if we have any to send"
      return if to_send.empty?
      @data = { :translations => to_send }
      Localeapp.debug "post_missing_translations: turning data into json"
      json = @data.to_json
      Localeapp.debug "post_missing_translations: making api call"
      api_call :missing_translations,
        :payload => json,
        :headers => { :content_type => :json },
        :success => :handle_missing_translation_success,
        :failure => :handle_missing_translation_failure,
        :max_connection_attempts => 1
    end

    def handle_missing_translation_success(response)
      Localeapp.debug "post_missing_translations: success callback"
      Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def handle_missing_translation_failure(response)
      Localeapp.debug "post_missing_translations: failure callback"
      Localeapp.log([translations_url, response.code, @data.inspect].join(' - '))
    end
  end
end
