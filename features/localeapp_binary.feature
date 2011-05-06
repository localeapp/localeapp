Feature: localeapp executable

  Scenario: Viewing help
    In order to see what options I have
    When I run `localeapp help`
    Then the output should contain:
    """
    Usage: localeapp COMMAND [ARGS]

    Commands:
      install <api_key> - Creates new configuration files and confirms key works
      pull              - Pulls all translations from LocaleApp.com
    """

  Scenario: Running install
    In order to configure my project and check my api key is correct
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I run `localeapp install MYAPIKEY`
    Then the output should contain:
    """
    LocaleApp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And a file named "config/initializers/locale_app.rb" should exist

  Scenario: Running pull
    In order to retreive my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And a file named "config/initializers/locale_app.rb" with:
    """
    require 'locale_app/rails'
    LocaleApp.configure do |config|
      config.api_key = 'MYAPIKEY'
    end
    """
    And a directory named "config/locales"
    When I run `localeapp pull`
    Then the output should contain:
    """
    LocaleApp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And a file named "config/locales/en.yml" should exist