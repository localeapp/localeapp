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

  Scenario: Running pull with no initializer file, passing the key on the command line
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And a directory named "config/locales"
    And a directory named "log"
    When I successfully run `localeapp -k MYAPIKEY pull`
    Then the output should contain:
    """
    Localeapp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And a file named "config/locales/en.yml" should exist
