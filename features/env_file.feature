Feature: Reading configuration from `.env' file

  Scenario: Uses the API key from `.env' file
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I have a .env file containing the api key "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the exit status must be 0
