INITIALIZER_PATH = "config/initializers/localeapp.rb".freeze
DEFAULT_INITIALIZER = <<-eoh.freeze
require "localeapp/rails"

Localeapp.configure do |config|
  config.api_key = "MYAPIKEY"
end
eoh

def write_initializer_file(content = DEFAULT_INITIALIZER)
  write_file INITIALIZER_PATH, content
end


Given /^an initializer file with:$/ do |content|
  write_initializer_file content
end

Given /^an initializer file$/ do
  write_initializer_file
end
