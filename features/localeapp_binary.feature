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
    And the exit status should be 0

  Scenario: Running install with bad api key
    In order to configure my project and check my api key is correct
    When I have a valid project on localeapp.com but an incorrect api key "BADAPIKEY"
    And I run `localeapp install BADAPIKEY`
    Then the output should contain:
    """
    LocaleApp Install

    Checking API key: BADAPIKEY
    ERROR: Project not found
    """
    And a file named "config/initializers/locale_app.rb" should not exist
    And the exit status should not be 0

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

  Scenario: Running push
    In order to send my translations
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And a file named "config/initializers/locale_app.rb" with:
    """
    require 'locale_app/rails'
    LocaleApp.configure do |config|
      config.api_key = 'MYAPIKEY'
    end
    """
    And an empty file named "config/locales/en.yml"
    When I run `localeapp push config/locales/en.yml`
    Then the output should contain:
    """
    LocaleApp Push

    Pushing file:
    Success!

    config/locales/en.yml queued for processing.
    """
