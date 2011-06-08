require 'rest-client'
require 'json'

module LocaleApp
  class Sender
    include ::LocaleApp::ApiCall
    include ::LocaleApp::Routes

    def post_translation(locale, key, options, value = nil)
      options ||= {}
      translation = { :key => key, :locale => locale, :substitutions => options.keys, :description => value}
      @data = { :translation => translation }
      api_call :create_translation,
        :payload => @data.to_json,
        :request_options => { :content_type => :json },
        :success => :handle_single_translation_success,
        :failure => :handle_single_translation_failure,
        :max_connection_attempts => 1
    end

    def handle_single_translation_success(response)
       LocaleApp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def handle_single_translation_failure(response)
       LocaleApp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def post_missing_translations
      to_send = LocaleApp.missing_translations.to_send
      return if to_send.empty?
      @data = { :translations => to_send }
      api_call :missing_translations,
        :payload => @data.to_json,
        :request_options => { :content_type => :json },
        :success => :handle_missing_translation_success,
        :failure => :handle_missing_translation_failure,
        :max_connection_attempts => 1
    end

    def handle_missing_translation_success(response)
       LocaleApp.log([translations_url, response.code, @data.inspect].join(' - '))
    end

    def handle_missing_translation_failure(response)
       LocaleApp.log([translations_url, response.code, @data.inspect].join(' - '))
    end
  end
end
