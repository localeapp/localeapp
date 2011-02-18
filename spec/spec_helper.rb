require 'i18n'
require 'locale_app'

def with_configuration(options)
  LocaleApp.configure do |configuration|
    options.each do |option, value| 
      configuration.send("#{option}=", value)
    end
  end
  yield
end

RSpec.configure do |config|

end
