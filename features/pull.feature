Feature: Pulling all translation

  Scenario: Running pull
    In order to retrieve my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    And a directory named "config/locales"
    When I run `localeapp pull`
    Then the output should contain:
    """
    Localeapp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist

  Scenario: Running pull without having a locales dir
    In order to retreive my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp pull`
    Then the output should contain:
    """
    Could not write locale file, please make sure that config/locales exists and is writable
    """

  Scenario: Running pull with no initializer file, passing the key on the command line
    In order to retrieve my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And a directory named "config/locales"
    When I run `localeapp -k MYAPIKEY pull`
    Then the output should contain:
    """
    Localeapp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist
