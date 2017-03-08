Feature: `-k' global option (`--api-key')

  Scenario: Uses the API key given as `-k' option
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY add foo en:"en content"`
    Then the exit status must be 0
