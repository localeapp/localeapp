Feature: Reading configuration from environment

  Scenario: Uses the API key set in current environment
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I have a LOCALEAPP_API_KEY env variable set to "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the exit status must be 0
