module Localeapp
  module ApiCall
    # creates an object to perform the call
    def api_call(endpoint, options = {})
      api_caller = Localeapp::ApiCaller.new(endpoint, options)
      api_caller.call(self)
    end
  end
end
