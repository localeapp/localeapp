Feature: `pull' command

  Scenario: Pulls translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    And a directory named "config/locales"
    And a directory named "log"
    When I successfully run `localeapp pull`
    Then the output should contain:
    """
    Localeapp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And a file named "config/locales/en.yml" should exist

  Scenario: Reports an error when locales directory is missing
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp pull`
    Then the exit status must be 1
    And the output should contain:
    """
    Could not write locale file, please make sure that config/locales exists and is writable
    """

  Scenario: Reports an error when the given API key is incorrect
    Given no project exist on localeapp.com with API key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY pull`
    Then the exit status must be 70
    And the output must match /error.+404/i
