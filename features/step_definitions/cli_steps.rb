require 'net/http'
require 'time'

Given /^no project exist on localeapp\.com with API key "([^"]+)"$/ do |api_key|
  add_fake_web_uri :any, /\Ahttps:\/\/api\.localeapp\.com\/.*/,
    [404, "Not Found"],
    ""
end

When /^I have a valid project on localeapp\.com with api key "([^"]*)"$/ do |api_key|
  uri = "https://api.localeapp.com/v1/projects/#{api_key}.json"
  body = valid_project_data.to_json
  add_fake_web_uri(:get, uri, ['200', 'OK'], body)
  add_fake_web_uri(:post, "https://api.localeapp.com/v1/projects/#{api_key}/import/", ['202', 'OK'], '')
  add_fake_web_uri(:post, "https://api.localeapp.com/v1/projects/#{api_key}/translations/missing.json", ["202", "OK"], '')
end

When /^I have a valid heroku project/ do
  uri = "https://api.localeapp.com/v1/projects/MYAPIKEY.json"
  body = valid_project_data.to_json
  add_fake_web_uri(:get, uri, ['200', 'OK'], body)
  set_environment_variable 'CUCUMBER_HEROKU_TEST_API_KEY', 'MYAPIKEY'
end

When /^I have a valid project on localeapp\.com but an incorrect api key "([^"]*)"$/ do |bad_api_key|
  uri = "https://api.localeapp.com/v1/projects/#{bad_api_key}.json"
  body = valid_project_data.to_json
  add_fake_web_uri(:get, uri, ['404', 'Not Found'], body)
end

When /^I have a translations on localeapp\.com for the project with api key "([^"]*)"$/ do |api_key|
  uri = "https://api.localeapp.com/v1/projects/#{api_key}/translations/all.yml"
  body = valid_export_data.to_yaml
  add_fake_web_uri(:get, uri, ['200', 'OK'], body)
end

When /^new translations for the api key "([^"]*)" since "([^"]*)" with time "([^"]*)"$/ do |api_key, update_time, new_time|
  uri = "https://api.localeapp.com/v1/projects/#{api_key}/translations.yml?updated_at=#{update_time}"
  body = valid_translation_data.to_yaml
  add_fake_web_uri(:get, uri, ['200', 'OK'], body, 'date' => Time.at(new_time.to_i).httpdate)
end

When /^new translations for the api key "([^"]*)" since last fetch with time "([^"]*)" seconds later$/ do |api_key, time_shift|
  steps %Q{
    When new translations for the api key "#{api_key}" since "#{@timestamp}" with time "#{@timestamp + time_shift.to_i}"
  }
end

When /^I have a valid project on localeapp\.com with api key "([^"]*)" and the translation key "([^"]*)"/ do |api_key, key_name|
  uri = "https://api.localeapp.com/v1/projects/#{api_key}/translations/#{key_name.gsub(/\./, '%2E')}"
  add_fake_web_uri(:delete, uri, ['200', 'OK'], '')
  add_fake_web_uri(:post, uri + '/rename', ['200', 'OK'], '')
end

When /^I have a LOCALEAPP_API_KEY env variable set to "(.*?)"$/ do |api_key|
  set_environment_variable 'LOCALEAPP_API_KEY', api_key
end

When /^I have a \.env file containing the api key "(.*?)"$/ do |api_key|
  steps %Q{
    And a file named ".env" with:
    """
    LOCALEAPP_API_KEY=#{api_key}
    """
  }
end

When /^an initializer file$/ do
  steps %Q{
    And a file named "config/initializers/localeapp.rb" with:
    """
    require 'localeapp/rails'
    Localeapp.configure do |config|
      config.api_key = 'MYAPIKEY'
    end
    """
  }
end

When /^the timestamp is (\d+) months? old$/ do |months|
  @timestamp = Time.now.to_i - months.to_i * 2592000
  steps %Q{
    And a file named "log/localeapp.yml" with:
    """
    ---
    :updated_at: #{@timestamp}
    :polled_at: #{@timestamp}
    """
  }
end

Then /^translations should be fetched since last fetch only$/ do
  steps %Q{
    Then the output should contain:
    """
    Localeapp update: checking for translations since #{@timestamp}
    Found and updated new translations
    """
  }
end
