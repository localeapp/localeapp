Feature: `push' command

  Scenario: Pushes translations in a specific locales file
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And an empty file named "config/locales/en.yml"
    When I run `localeapp push config/locales/en.yml`
    Then the output should contain:
    """
    Localeapp Push

    Pushing file en.yml:
    Success!

    config/locales/en.yml queued for processing.
    """
    And help should not be displayed

  Scenario: Pushes all locales within given directory
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And an empty file named "config/locales/en.yml"
    And an empty file named "config/locales/es.yml"
    When I run `localeapp push config/locales`
    Then the output should contain:
    """
    Localeapp Push

    Pushing file en.yml:
    Success!

    config/locales/en.yml queued for processing.

    Pushing file es.yml:
    Success!

    config/locales/es.yml queued for processing.
    """
    And help should not be displayed

  Scenario: Pushes a locale file when given the API key on the command line
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an empty file named "config/locales/en.yml"
    When I run `localeapp -k MYAPIKEY push config/locales/en.yml`
    Then the output should contain:
    """
    Localeapp Push

    Pushing file en.yml:
    Success!

    config/locales/en.yml queued for processing.
    """
    And help should not be displayed
