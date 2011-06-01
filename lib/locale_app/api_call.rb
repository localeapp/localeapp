module LocaleApp
  module ApiCall
    # creates an object to perform the call
    def api_call(endpoint, options = {})
      api_caller = LocaleApp::ApiCaller.new(endpoint, options)
      api_caller.call(self)
    end
  end
end
