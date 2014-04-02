Feature: Getting new translations

  Scenario: Running update
    In order to receive the translations that have been updated since the last check
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And the timestamp is 2 months old
    And new translations for the api key "MYAPIKEY" since last fetch with time "60" seconds later
    And a directory named "config/locales"
    When I run `localeapp update`
    Then translations should be fetched since last fetch only
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist
    # check the content here
    # and the localeapp.yml file

  Scenario: Running update with no initializer file, passing the key on the command line
    In order to receive the translations that have been updated since the last check
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And the timestamp is 2 months old
    And new translations for the api key "MYAPIKEY" since last fetch with time "60" seconds later
    And a directory named "config/locales"
    When I run `localeapp -k MYAPIKEY update`
    Then translations should be fetched since last fetch only
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist

  Scenario: Running update with a too old timestamp
    In order to receive the translations that have been updated since the last check
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And the timestamp is 8 months old
    When I run `localeapp update`
    Then the output should contain:
    """
    Timestamp is missing or too old
    """
    And help should not be displayed
