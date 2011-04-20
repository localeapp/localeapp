require 'net/http'
When /^I have a valid project on localeapp\.com with api key "([^"]*)"$/ do |api_key|
  uri = "http://api.localeapp.com/projects/#{api_key}.json"
  body = valid_project_data.to_json
  add_fake_web_uri(:get, uri, ['200', 'OK'], body)
end
