Feature: Getting new translations

  Scenario: Running update
    In order to receive the translations that have been updated since the last check
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And a file named "log/localeapp.yml" with:
    """
    ---
    :updated_at: 120
    :polled_at: 130
    """
    And new translations for the api key "MYAPIKEY" since "120" with time "140"
    And a directory named "config/locales"
    When I run `localeapp update`
    Then the output should contain:
    """
    Localeapp update: checking for translations since 120
    Found and updated new translations
    """
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist
    # check the content here
    # and the localeapp.yml file
