Feature: `update' command

  Scenario: Fetches translations
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And the timestamp is 2 months old
    And new translations for the api key "MYAPIKEY" since last fetch with time "60" seconds later
    And a directory named "config/locales"
    When I successfully run `localeapp update`
    Then translations should be fetched since last fetch only
    And a file named "config/locales/en.yml" should exist

  Scenario: Reports an error when timestamp is too old
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And the timestamp is 8 months old
    When I successfully run `localeapp update`
    Then the output should contain:
    """
    Timestamp is missing or too old
    """

  Scenario: Reports an error when the given API key is incorrect
    Given no project exist on localeapp.com with API key "MYAPIKEY"
    And the timestamp is 2 months old
    And a directory named "config/locales"
    When I run `localeapp -k MYAPIKEY update`
    Then the exit status must be 70
    And the output must match /error.+404/i
